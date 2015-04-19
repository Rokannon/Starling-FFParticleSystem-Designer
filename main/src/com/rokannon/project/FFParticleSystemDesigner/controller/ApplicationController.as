package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.command.enum.CommandState;
    import com.rokannon.core.utils.string.getExtension;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.ParticleModel;

    import de.flintfabrik.starling.display.FFParticleSystem;
    import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

    import feathers.controls.Alert;
    import feathers.data.ListCollection;

    import flash.display.Bitmap;
    import flash.filesystem.File;

    import starling.core.Starling;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import treefortress.textureutils.AtlasBuilder;

    public class ApplicationController
    {
        public const configController:ConfigController = new ConfigController();
        public const localStorageController:LocalStorageController = new LocalStorageController();

        private var _appModel:ApplicationModel;
        private var _appView:ApplicationView;

        public function ApplicationController()
        {
        }

        public function connect(appModel:ApplicationModel, appView:ApplicationView):void
        {
            _appModel = appModel;
            _appView = appView;
            configController.connect(_appModel, _appView, this);
            localStorageController.connect(_appModel, _appView, this);
        }

        public function startApplication():void
        {
            _appModel.commandExecutor.eventExecuteStart.add(_appView.lockButtons);
            _appModel.commandExecutor.eventExecuteEnd.add(_appView.unlockButtons);
            if (_appModel.commandExecutor.isExecuting)
                _appView.lockButtons();

            FFParticleSystem.init(4096, false, 4096, 16);

            _appModel.commandExecutor.pushMethod(localStorageController.setupLocalStorage, null, false);
            _appModel.commandExecutor.pushMethod(configController.loadConfig, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(loadParticleSystem, CommandState.COMPLETE);
        }

        public function loadParticleSystem():Boolean
        {
            _appModel.commandExecutor.pushMethod(doLoadParticleSystem);
            return true;
        }

        private function doLoadParticleSystem():Boolean
        {
            _appModel.commandExecutor.pushMethod(doUnloadParticleSystem, CommandState.COMPLETE);
            var directoryListingCommandData:DirectoryListingCommandData = new DirectoryListingCommandData();
            directoryListingCommandData.directoryToLoad = _appModel.particleModel.particleDirectory;
            directoryListingCommandData.fileModel = _appModel.fileModel;
            _appModel.commandExecutor.pushCommand(new DirectoryListingCommand(directoryListingCommandData));
            _appModel.commandExecutor.pushMethod(handleParticleDirectoryError, CommandState.FAILED);
            _appModel.commandExecutor.pushMethod(doLoadPexFile, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(handlePexFileError, CommandState.FAILED);
            _appModel.commandExecutor.pushMethod(doLoadAtlasXmlFile, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(handleAtlasXmlError, CommandState.FAILED);
            _appModel.commandExecutor.pushMethod(doLoadTexture, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(handleLoadTextureError, CommandState.FAILED);
            _appModel.commandExecutor.pushMethod(doCreateParticleSystem, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(configController.saveConfig, CommandState.COMPLETE);
            return true;
        }

        private function handleParticleDirectoryError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_PARTICLE_FOLDER, ErrorTitle.ERROR, buttonCollection);
            return false;
        }

        private function doLoadPexFile():Boolean
        {
            var fileLoadCommandData:FileLoadCommandData = new FileLoadCommandData();
            fileLoadCommandData.fileModel = _appModel.fileModel;
            for each (var file:File in _appModel.fileModel.directoryListing)
            {
                if (getExtension(file.nativePath) == "pex")
                    fileLoadCommandData.fileToLoad = file;
            }
            if (fileLoadCommandData.fileToLoad == null)
                return false;
            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData), CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(parsePexFile, CommandState.COMPLETE);
            return true;
        }

        private function parsePexFile():Boolean
        {
            try
            {
                _appModel.particleModel.particlePex = new XML(_appModel.fileModel.fileContent.toString());
            }
            catch (error:Error)
            {
                return false;
            }
            return true;
        }

        private function handlePexFileError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_PEX_FILE, ErrorTitle.ERROR, buttonCollection);
            return false;
        }

        private function doLoadAtlasXmlFile():Boolean
        {
            var fileLoadCommandData:FileLoadCommandData = new FileLoadCommandData();
            fileLoadCommandData.fileModel = _appModel.fileModel;
            for each (var file:File in _appModel.fileModel.directoryListing)
            {
                if (getExtension(file.nativePath) == "xml")
                    fileLoadCommandData.fileToLoad = file;
            }
            if (fileLoadCommandData.fileToLoad == null)
                return true; // No XML is OK.
            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData));
            _appModel.commandExecutor.pushMethod(parseAtlasXml, CommandState.COMPLETE);
            return true;
        }

        private function parseAtlasXml():Boolean
        {
            try
            {
                _appModel.particleModel.particleAtlasXml = new XML(_appModel.fileModel.fileContent.toString());
            }
            catch (error:Error)
            {
                return false;
            }
            return true;
        }

        private function handleAtlasXmlError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_ATLAS_XML, ErrorTitle.ERROR, buttonCollection);
            return false;
        }

        private function doLoadTexture():Boolean
        {
            var bitmaps:Vector.<Bitmap> = new <Bitmap>[];
            for each (var file:File in _appModel.fileModel.directoryListing)
            {
                if (getExtension(file.nativePath) != "png")
                    continue;

                var fileLoadCommandData:FileLoadCommandData = new FileLoadCommandData();
                fileLoadCommandData.fileModel = _appModel.fileModel;
                fileLoadCommandData.fileToLoad = file;
                _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData), CommandState.COMPLETE);

                var createBitmapCommandData:CreateBitmapCommandData = new CreateBitmapCommandData();
                createBitmapCommandData.fileModel = _appModel.fileModel;
                _appModel.commandExecutor.pushCommand(new CreateBitmapCommand(createBitmapCommandData),
                    CommandState.COMPLETE);

                _appModel.commandExecutor.pushMethod(function ():Boolean
                {
                    bitmaps.push(_appModel.fileModel.fileBitmap);
                    return true;
                }, CommandState.COMPLETE);
            }
            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                if (bitmaps.length == 1)
                {
                    _appModel.particleModel.particleTexture = Texture.fromBitmapData(bitmaps[0].bitmapData);
                    return true;
                }
                if (bitmaps.length == 0 || _appModel.particleModel.particleAtlasXml != null)
                    return false;

                var textureAtlas:TextureAtlas = AtlasBuilder.build(bitmaps, 1.0);
                _appModel.particleModel.particleTexture = textureAtlas.texture;
                _appModel.particleModel.particleAtlasXml = AtlasBuilder.atlasXml;
                return true;
            }, CommandState.COMPLETE);
            return true;
        }

        private function handleLoadTextureError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_TEXTURE, ErrorTitle.ERROR, buttonCollection);
            return false;
        }

        public function resetParticleSystem():void
        {
            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                _appModel.commandExecutor.pushMethod(localStorageController.setupLocalStorage, CommandState.COMPLETE,
                    true);
                _appModel.commandExecutor.pushMethod(configController.loadConfig, CommandState.COMPLETE);
                _appModel.commandExecutor.pushMethod(loadParticleSystem, CommandState.COMPLETE);
                return true;
            });
        }

        public function browseParticleSystem():void
        {
            var directoryBrowseCommandData:DirectoryBrowseCommandData = new DirectoryBrowseCommandData();
            directoryBrowseCommandData.browseTitle = "Select Folder";
            var particleDirectory:File = new File();
            directoryBrowseCommandData.directoryToBrowse = particleDirectory;
            var directoryBrowseCommand:DirectoryBrowseCommand = new DirectoryBrowseCommand(directoryBrowseCommandData);
            _appModel.commandExecutor.pushCommand(directoryBrowseCommand);

            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                if (directoryBrowseCommand.browseCanceled)
                {
                    _appModel.commandExecutor.removeAllCommands();
                    return false;
                }
                else if (_appModel.commandExecutor.lastCommandResult == CommandState.FAILED)
                {
                    _appModel.commandExecutor.removeAllCommands();
                    var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
                    Alert.show(ErrorMessage.BAD_PARTICLE_FOLDER, ErrorTitle.ERROR, buttonCollection);
                    return false;
                }
                else
                {
                    _appModel.particleModel.particleDirectory = particleDirectory;
                    loadParticleSystem();
                    return true;
                }
            });
        }

        public function openParticleSystemLocation():void
        {
            _appModel.particleModel.particleDirectory.openWithDefaultApplication();
        }

        private function doUnloadParticleSystem():Boolean
        {
            _appView.particleSystemLayer.removeChildren(0, -1, true);
            _appModel.particleModel.particleAtlasXml = null;
            _appModel.particleModel.particlePex = null;
            if (_appModel.particleModel.particleTexture != null)
            {
                _appModel.particleModel.particleTexture.dispose();
                _appModel.particleModel.particleTexture = null;
            }
            return true;
        }

        private function doCreateParticleSystem():Boolean
        {
            var particleModel:ParticleModel = _appModel.particleModel;
            var systemOptions:SystemOptions = SystemOptions.fromXML(particleModel.particlePex,
                particleModel.particleTexture, particleModel.particleAtlasXml);
            if (_appModel.particleModel.appendFromObject != null)
                systemOptions.appendFromObject(_appModel.particleModel.appendFromObject);
            var particleSystem:FFParticleSystem = new FFParticleSystem(systemOptions);
            _appView.particleSystemLayer.addChild(particleSystem);
            particleSystem.start();
            Starling.juggler.add(particleSystem);
            return true;
        }
    }
}