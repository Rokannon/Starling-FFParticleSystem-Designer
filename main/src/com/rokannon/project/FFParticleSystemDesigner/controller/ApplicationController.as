package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.command.enum.CommandState;
    import com.rokannon.core.utils.string.getExtension;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.ParticleModel;

    import de.flintfabrik.starling.display.FFParticleSystem;
    import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

    import feathers.controls.Alert;
    import feathers.data.ListCollection;

    import flash.desktop.NativeApplication;
    import flash.display.Bitmap;
    import flash.filesystem.File;

    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import treefortress.textureutils.AtlasBuilder;

    public class ApplicationController
    {
        public const configController:ConfigController = new ConfigController();

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
        }

        public function startApplication():void
        {
            _appModel.commandExecutor.eventExecuteStart.add(_appView.lockButtons);
            _appModel.commandExecutor.eventExecuteEnd.add(_appView.unlockButtons);

            FFParticleSystem.init(4096, false, 4096, 16);

            setupLocalStorage(false);
            configController.loadConfig();
            loadParticleSystem();
        }

        public function browseParticleSystem():void
        {
            var directoryBrowseCommandData:DirectoryBrowseCommandData = new DirectoryBrowseCommandData();
            directoryBrowseCommandData.browseTitle = "Select Folder";
            var particleDirectory:File = new File();
            directoryBrowseCommandData.directoryToBrowse = particleDirectory;
            var directoryBrowseCommand:DirectoryBrowseCommand = new DirectoryBrowseCommand(directoryBrowseCommandData);
            _appModel.commandExecutor.pushCommand(directoryBrowseCommand);

            _appModel.commandExecutor.pushMethod(function ():Boolean {
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
                    configController.saveConfig(); // TODO Must be performed only after P.S. loaded.
                    reloadParticleSystem();
                    return true;
                }
            });
        }

        public function openParticleSystemLocation():void
        {
            _appModel.particleModel.particleDirectory.openWithDefaultApplication();
        }

        public function setupLocalStorage(overwrite:Boolean):void
        {
            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                var defaultConfigFile:File = File.applicationDirectory.resolvePath("default_config.json");
                if (!defaultConfigFile.exists)
                    return false;
                var demoParticleDirectory:File = File.applicationDirectory.resolvePath("demo_particle");
                if (!demoParticleDirectory.exists)
                    return false;
                var configFile:File = File.applicationStorageDirectory.resolvePath("config.json");
                _appModel.firstRun = !configFile.exists || configFile.modificationDate.time < defaultConfigFile.modificationDate.time;
                if (_appModel.firstRun || overwrite)
                {
                    var fileCopyCommandData:FileCopyCommandData;
                    fileCopyCommandData = new FileCopyCommandData();
                    fileCopyCommandData.directoryToCopyTo = File.applicationStorageDirectory;
                    fileCopyCommandData.fileToCopy = defaultConfigFile;
                    fileCopyCommandData.newFileName = "config.json";
                    fileCopyCommandData.overwrite = true;
                    _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData));

                    var directoryDeleteCommandData:DirectoryDeleteCommandData = new DirectoryDeleteCommandData();
                    directoryDeleteCommandData.deleteDirectoryContents = true;
                    directoryDeleteCommandData.directoryToDelete = File.applicationStorageDirectory.resolvePath("demo_particle");
                    _appModel.commandExecutor.pushCommand(new DirectoryDeleteCommand(directoryDeleteCommandData));

                    fileCopyCommandData = new FileCopyCommandData();
                    fileCopyCommandData.directoryToCopyTo = File.applicationStorageDirectory;
                    fileCopyCommandData.fileToCopy = demoParticleDirectory;
                    fileCopyCommandData.newFileName = null;
                    fileCopyCommandData.overwrite = true;
                    _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData));
                }
                return true;
            });

            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                if (_appModel.commandExecutor.lastCommandResult == CommandState.COMPLETE)
                    return true;
                _appModel.commandExecutor.removeAllCommands();
                var buttonCollection:ListCollection = new ListCollection([{label: "Exit"}]);
                var alert:Alert = Alert.show(ErrorMessage.APPLICATION_FOLDER_CORRUPTED, ErrorTitle.FATAL_ERROR,
                    buttonCollection);
                alert.addEventListener(Event.CLOSE, function (event:Event):void
                {
                    NativeApplication.nativeApplication.exit();
                });
                return false;
            });
        }

        public function reloadParticleSystem():void
        {
            _appModel.commandExecutor.pushMethod(deReloadParticleSystem);
        }

        private function deReloadParticleSystem():void
        {
            unloadParticleSystem();
            configController.loadConfig();
            loadParticleSystem();
        }

        public function unloadParticleSystem():void
        {
            _appView.particleSystemLayer.removeChildren(0, -1, true);
            _appModel.particleModel.appendFromObject = null;
            _appModel.particleModel.particleAtlasXml = null;
            _appModel.particleModel.particleDirectory = null;
            _appModel.particleModel.particlePex = null;
            if (_appModel.particleModel.particleTexture != null)
            {
                _appModel.particleModel.particleTexture.dispose();
                _appModel.particleModel.particleTexture = null;
            }
        }

        public function loadParticleSystem():void
        {
            _appModel.commandExecutor.pushMethod(doLoadParticleSystem);
        }

        private function doLoadParticleSystem():Boolean
        {
            var directoryListingCommandData:DirectoryListingCommandData = new DirectoryListingCommandData();
            directoryListingCommandData.directoryToLoad = _appModel.particleModel.particleDirectory;
            directoryListingCommandData.fileModel = _appModel.fileModel;
            _appModel.commandExecutor.pushCommand(new DirectoryListingCommand(directoryListingCommandData));

            _appModel.commandExecutor.pushMethod(doLoadPexFile);
            _appModel.commandExecutor.pushMethod(doLoadAtlasXmlFile);
            _appModel.commandExecutor.pushMethod(doLoadTexture);
            _appModel.commandExecutor.pushMethod(doCreateParticleSystem);

            return true;
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
            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData));

            _appModel.commandExecutor.pushMethod(function ():Boolean
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
            });

            return true;
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

            _appModel.commandExecutor.pushMethod(function ():Boolean
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
            });

            return true;
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
                _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData));

                var createBitmapCommandData:CreateBitmapCommandData = new CreateBitmapCommandData();
                createBitmapCommandData.fileModel = _appModel.fileModel;
                _appModel.commandExecutor.pushCommand(new CreateBitmapCommand(createBitmapCommandData));

                _appModel.commandExecutor.pushMethod(function ():Boolean
                {
                    bitmaps.push(_appModel.fileModel.fileBitmap);
                    return true;
                });
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
            });
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