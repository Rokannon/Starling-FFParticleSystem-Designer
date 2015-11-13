package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.command.bitmapLoad.BitmapLoadCommand;
    import com.rokannon.command.bitmapLoad.BitmapLoadContext;
    import com.rokannon.command.directoryListing.DirectoryListingCommand;
    import com.rokannon.command.directoryListing.DirectoryListingContext;
    import com.rokannon.command.fileLoad.FileLoadCommand;
    import com.rokannon.command.fileLoad.FileLoadContext;
    import com.rokannon.core.utils.string.getExtension;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.ParticleModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.params.BrowseParticleSystemParams;
    import com.rokannon.project.FFParticleSystemDesigner.model.params.LoadParticleSystemParams;

    import de.flintfabrik.starling.display.FFParticleSystem;
    import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

    import feathers.controls.Alert;
    import feathers.data.ListCollection;

    import flash.display.Bitmap;
    import flash.filesystem.File;

    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import treefortress.textureutils.AtlasBuilder;

    public class ParticleSystemController
    {
        private static const helperFiles:Vector.<File> = new <File>[];

        private var _appModel:ApplicationModel;
        private var _appView:ApplicationView;
        private var _appController:ApplicationController;

        public function ParticleSystemController()
        {
        }

        public function connect(appModel:ApplicationModel, appView:ApplicationView,
                                appController:ApplicationController):void
        {
            _appModel = appModel;
            _appView = appView;
            _appController = appController;
        }

        //
        // Load Particle System
        //

        public function loadParticleSystem(handleErrors:Boolean):void
        {
            var loadParticleSystemParams:LoadParticleSystemParams = new LoadParticleSystemParams();
            loadParticleSystemParams.handleErrors = handleErrors;
            _appModel.commandExecutor.pushMethod(doLoadParticleSystem, true, loadParticleSystemParams);
            if (!handleErrors)
                _appModel.commandExecutor.pushMethod(_appController.resetError, false);
        }

        private function doLoadParticleSystem(loadParticleSystemParams:LoadParticleSystemParams):Boolean
        {
            _appModel.commandExecutor.pushMethod(doUnloadParticleSystem);
            var directoryListingContext:DirectoryListingContext = new DirectoryListingContext();
            directoryListingContext.directoryToLoad = _appModel.particleModel.particleDirectory;
            _appModel.commandExecutor.pushCommand(new DirectoryListingCommand(directoryListingContext));
            _appController.moveDirectoryListingToModel(directoryListingContext);
            if (loadParticleSystemParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handleParticleDirectoryError, false);
            _appModel.commandExecutor.pushMethod(doLoadPexFile);
            if (loadParticleSystemParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handlePexFileError, false);
            _appModel.commandExecutor.pushMethod(doLoadAtlasXmlFile);
            if (loadParticleSystemParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handleAtlasXmlError, false);
            _appModel.commandExecutor.pushMethod(doLoadTexture, true, loadParticleSystemParams);
            if (loadParticleSystemParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handleLoadTextureError, false);
            _appModel.commandExecutor.pushMethod(doCreateParticleSystem);
            _appController.configController.saveConfig();
            return true;
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

        private function handleParticleDirectoryError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_PARTICLE_FOLDER, ErrorTitle.ERROR, buttonCollection);
            return true;
        }

        private function doLoadPexFile():Boolean
        {
            var fileLoadContext:FileLoadContext = new FileLoadContext();
            for each (var file:File in _appModel.fileModel.directoryListing)
            {
                if (getNativeExtension(file.nativePath) == "pex")
                    fileLoadContext.fileToLoad = file;
            }
            if (fileLoadContext.fileToLoad == null)
                return false;

            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadContext));
            _appController.moveLoadedFileToModel(fileLoadContext);
            _appModel.commandExecutor.pushMethod(parsePexFile);
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
            return true;
        }

        private function doLoadAtlasXmlFile():Boolean
        {
            var fileLoadContext:FileLoadContext = new FileLoadContext();
            for each (var file:File in _appModel.fileModel.directoryListing)
            {
                if (getNativeExtension(file.nativePath) == "xml")
                    fileLoadContext.fileToLoad = file;
            }
            if (fileLoadContext.fileToLoad == null)
                return true; // No XML is OK.

            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadContext));
            _appController.moveLoadedFileToModel(fileLoadContext);
            _appModel.commandExecutor.pushMethod(parseAtlasXml);
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
            return true;
        }

        private function doLoadTexture(loadParticleSystemParams:LoadParticleSystemParams):Boolean
        {
            // Attempting to find texture possibly defined in .pex config.
            var textureName:String = _appModel.particleModel.particlePex.texture.attribute("name");
            for each (file in _appModel.fileModel.directoryListing)
            {
                if (file.name == textureName)
                {
                    helperFiles.length = 0;
                    helperFiles.push(file);
                    break;
                }
                else
                    helperFiles.push(file);
            }
            // Now helperFiles has either a single file provided in .pex config
            // or simply all files from directory listing.

            loadParticleSystemParams.bitmaps = new <Bitmap>[];

            var file:File;
            var fileLoadContext:FileLoadContext;

            // Attempt to load ATF texture.
            for each (file in helperFiles)
            {
                if (getNativeExtension(file.nativePath) != "atf")
                    continue;

                fileLoadContext = new FileLoadContext();
                fileLoadContext.fileToLoad = file;
                _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadContext));
                _appController.moveLoadedFileToModel(fileLoadContext);
                _appModel.commandExecutor.pushMethod(createATFTexture);
                helperFiles.length = 0;
                return true;
            }

            // ATF not found. Searching for PNG file(s).
            for each (file in helperFiles)
            {
                if (getNativeExtension(file.nativePath) != "png")
                    continue;

                fileLoadContext = new FileLoadContext();
                fileLoadContext.fileToLoad = file;
                _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadContext));
                _appController.moveLoadedFileToModel(fileLoadContext);
                var bitmapLoadContext:BitmapLoadContext = new BitmapLoadContext();
                _appController.moveModelToBitmapLoadContext(bitmapLoadContext);
                _appModel.commandExecutor.pushCommand(new BitmapLoadCommand(bitmapLoadContext));
                _appController.moveLoadedBitmapToModel(bitmapLoadContext);

                _appModel.commandExecutor.pushMethod(addBitmap, true, loadParticleSystemParams);
            }
            _appModel.commandExecutor.pushMethod(createAtlas, true, loadParticleSystemParams);
            helperFiles.length = 0;
            return true;
        }

        private function createATFTexture():Boolean
        {
            _appModel.particleModel.particleTexture = Texture.fromAtfData(_appModel.fileModel.fileContent);
            return true;
        }

        private function addBitmap(loadParticleSystemParams:LoadParticleSystemParams):Boolean
        {
            loadParticleSystemParams.bitmaps.push(_appModel.fileModel.fileBitmap);
            return true;
        }

        private function createAtlas(loadParticleSystemParams:LoadParticleSystemParams):Boolean
        {
            if (loadParticleSystemParams.bitmaps.length == 1)
            {
                _appModel.particleModel.particleTexture = Texture.fromBitmapData(loadParticleSystemParams.bitmaps[0].bitmapData);
                return true;
            }
            if (loadParticleSystemParams.bitmaps.length == 0 || _appModel.particleModel.particleAtlasXml != null)
                return false;

            var textureAtlas:TextureAtlas = AtlasBuilder.build(loadParticleSystemParams.bitmaps, 1.0);
            _appModel.particleModel.particleTexture = textureAtlas.texture;
            _appModel.particleModel.particleAtlasXml = AtlasBuilder.atlasXml;
            return true;
        }

        private function handleLoadTextureError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_TEXTURE, ErrorTitle.ERROR, buttonCollection);
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
            _appModel.starlingInstance.juggler.add(particleSystem);
            _appModel.particleModel.particleLoadTime = new Date().getTime();
            return true;
        }

        //
        // Reset Particle System
        //

        public function resetParticleSystem():void
        {
            _appController.localStorageController.setupLocalStorage(true, true);
            _appController.configController.loadConfig(true);
            loadParticleSystem(true);
        }

        //
        // Browse Particle System
        //

        public function browseParticleSystem(handleErrors:Boolean):void
        {
            var browseParticleSystemData:BrowseParticleSystemParams = new BrowseParticleSystemParams();
            browseParticleSystemData.handleErrors = handleErrors;
            _appModel.commandExecutor.pushMethod(doBrowseParticleSystem_step1, true, browseParticleSystemData);
            if (!handleErrors)
                _appModel.commandExecutor.pushMethod(_appController.resetError, false);
        }

        private function doBrowseParticleSystem_step1(browseParticleSystemData:BrowseParticleSystemParams):Boolean
        {
            var directoryBrowseCommandData:DirectoryBrowseCommandData = new DirectoryBrowseCommandData();
            directoryBrowseCommandData.browseTitle = "Select Folder";
            var particleDirectory:File = new File();
            directoryBrowseCommandData.directoryToBrowse = particleDirectory;
            var directoryBrowseCommand:DirectoryBrowseCommand = new DirectoryBrowseCommand(directoryBrowseCommandData);
            _appModel.commandExecutor.pushCommand(directoryBrowseCommand);
            _appModel.commandExecutor.pushMethod(handleDirectoryBrowseError, false);
            browseParticleSystemData.directoryBrowseCommand = directoryBrowseCommand;
            browseParticleSystemData.particleDirectory = particleDirectory;
            _appModel.commandExecutor.pushMethod(doBrowseParticleSystem_step2, true, browseParticleSystemData);
            return true;
        }

        private function handleDirectoryBrowseError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            return true;
        }

        private function doBrowseParticleSystem_step2(browseParticleSystemData:BrowseParticleSystemParams):Boolean
        {
            if (browseParticleSystemData.directoryBrowseCommand.browseCanceled)
            {
                _appModel.commandExecutor.removeAllCommands();
                return true;
            }
            else if (!_appModel.commandExecutor.lastCommandResult)
            {
                if (browseParticleSystemData.handleErrors)
                    _appModel.commandExecutor.pushMethod(handleBrowseParticleSystemError);
                return false;
            }
            else
            {
                _appModel.particleModel.particleDirectory = browseParticleSystemData.particleDirectory;
                loadParticleSystem({});
                return true;
            }
        }

        private function handleBrowseParticleSystemError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Ok"}]);
            Alert.show(ErrorMessage.BAD_PARTICLE_FOLDER, ErrorTitle.ERROR, buttonCollection);
            return true;
        }

        //
        // Open Particle System Location
        //

        public function openParticleSystemLocation():void
        {
            _appModel.commandExecutor.pushMethod(doOpenParticleSystemLocation);
        }

        private function doOpenParticleSystemLocation():Boolean
        {
            _appModel.particleModel.particleDirectory.openWithDefaultApplication();
            return true;
        }

        private static function getNativeExtension(path:String):String
        {
            return getExtension(path, File.separator);
        }
    }
}