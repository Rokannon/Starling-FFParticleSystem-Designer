package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.utils.getProperty;
    import com.rokannon.core.utils.requireProperty;
    import com.rokannon.core.utils.string.getExtension;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap.CreateBitmapCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing.DirectoryListingCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.ParticleModel;

    import de.flintfabrik.starling.display.FFParticleSystem;
    import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

    import flash.display.Bitmap;
    import flash.filesystem.File;

    import starling.core.Starling;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import treefortress.textureutils.AtlasBuilder;

    public class ApplicationController
    {
        private var _appModel:ApplicationModel;
        private var _appView:ApplicationView;

        public function ApplicationController()
        {
        }

        public function connect(appModel:ApplicationModel, appView:ApplicationView):void
        {
            _appModel = appModel;
            _appView = appView;
        }

        public function startApplication():void
        {
            _appModel.commandExecutor.eventExecuteStart.add(_appView.lockButtons);
            _appModel.commandExecutor.eventExecuteEnd.add(_appView.unlockButtons);

            FFParticleSystem.init(4096, false, 4096, 16);

            setupLocalStorage(false);
            loadConfig();
            loadParticleSystem();
        }

        public function openParticleSystemLocation():void
        {
            _appModel.particleModel.particleDirectory.openWithDefaultApplication();
        }

        public function setupLocalStorage(overwrite:Boolean):void
        {
            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                var configFile:File = File.applicationStorageDirectory.resolvePath("config.json");
                _appModel.firstRun = !configFile.exists;
                if (_appModel.firstRun || overwrite)
                {
                    var fileCopyCommandData:FileCopyCommandData;
                    fileCopyCommandData = new FileCopyCommandData();
                    fileCopyCommandData.directoryToCopyTo = File.applicationStorageDirectory;
                    fileCopyCommandData.fileToCopy = File.applicationDirectory.resolvePath("default_config.json");
                    fileCopyCommandData.newFileName = "config.json";
                    fileCopyCommandData.overwrite = true;
                    _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData));

                    var directoryDeleteCommandData:DirectoryDeleteCommandData = new DirectoryDeleteCommandData();
                    directoryDeleteCommandData.deleteDirectoryContents = true;
                    directoryDeleteCommandData.directoryToDelete = File.applicationStorageDirectory.resolvePath("demo_particle");
                    _appModel.commandExecutor.pushCommand(new DirectoryDeleteCommand(directoryDeleteCommandData));

                    fileCopyCommandData = new FileCopyCommandData();
                    fileCopyCommandData.directoryToCopyTo = File.applicationStorageDirectory;
                    fileCopyCommandData.fileToCopy = File.applicationDirectory.resolvePath("demo_particle");
                    fileCopyCommandData.newFileName = null;
                    fileCopyCommandData.overwrite = true;
                    _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData));
                }
                return true;
            });
        }

        public function reloadParticleSystem():void
        {
            unloadParticleSystem();
            loadConfig();
            loadParticleSystem();
        }

        public function unloadParticleSystem():void
        {
            _appView.particleSystemLayer.removeChildren(0, -1, true);
            _appModel.particleModel.appendFromObject = null;
            _appModel.particleModel.particleAtlasXml = null;
            _appModel.particleModel.particleDirectory = null;
            _appModel.particleModel.particlePex = null;
            _appModel.particleModel.particleTexture.dispose();
            _appModel.particleModel.particleTexture = null;
        }

        public function loadConfig():void
        {
            var fileLoadCommandData:FileLoadCommandData = new FileLoadCommandData();
            fileLoadCommandData.fileModel = _appModel.fileModel;
            fileLoadCommandData.fileToLoad = File.applicationStorageDirectory.resolvePath("config.json");
            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData));

            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                try
                {
                    var json:Object = JSON.parse(_appModel.fileModel.fileContent.toString());
                    _appModel.particleModel.particleDirectory = File.applicationStorageDirectory.resolvePath(requireProperty(json,
                        "particleDirectory"));
                    _appModel.particleModel.appendFromObject = getProperty(json, "appendFromObject", null);
                }
                catch (error:Error)
                {
                    return false;
                }
                return true;
            });
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