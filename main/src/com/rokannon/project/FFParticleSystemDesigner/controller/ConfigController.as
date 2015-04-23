package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.utils.getProperty;
    import com.rokannon.core.utils.requireProperty;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad.FileLoadCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileSave.FileSaveCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileSave.FileSaveCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.params.LoadConfigParams;

    import feathers.controls.Alert;
    import feathers.data.ListCollection;

    import flash.filesystem.File;
    import flash.utils.ByteArray;

    import starling.events.Event;

    public class ConfigController
    {
        private var _appModel:ApplicationModel;
        private var _appView:ApplicationView;
        private var _appController:ApplicationController;

        public function ConfigController()
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
        // Load Config
        //

        public function loadConfig(handleErrors:Boolean):void
        {
            var loadConfigParams:LoadConfigParams = new LoadConfigParams();
            loadConfigParams.handleErrors = handleErrors;
            _appModel.commandExecutor.pushMethod(doLoadConfig, true, loadConfigParams);
            if (!handleErrors)
                _appModel.commandExecutor.pushMethod(_appController.resetError, false);
        }

        private function doLoadConfig(loadConfigParams:LoadConfigParams):Boolean
        {
            var fileLoadCommandData:FileLoadCommandData = new FileLoadCommandData();
            fileLoadCommandData.fileModel = _appModel.fileModel;
            fileLoadCommandData.fileToLoad = File.applicationStorageDirectory.resolvePath("config.json");
            _appModel.commandExecutor.pushCommand(new FileLoadCommand(fileLoadCommandData));
            _appModel.commandExecutor.pushMethod(parseConfig);
            if (loadConfigParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handleParseError, false);
            return true;
        }

        private function parseConfig():Boolean
        {
            try
            {
                var json:Object = JSON.parse(_appModel.fileModel.fileContent.toString());
                _appModel.particleModel.particleDirectory = File.applicationStorageDirectory.resolvePath(requireProperty(json,
                    "particleDirectory"));
                _appModel.particleModel.appendFromObject = getProperty(json, "appendFromObject", null);
                _appModel.particleUpdateModel.setUpdateDelay(getProperty(json, "particleUpdateDelay", 1.0));
            }
            catch (error:Error)
            {
                return false;
            }
            return true;
        }

        private function handleParseError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Reset"}, {label: "Close"}]);
            var alert:Alert = Alert.show(ErrorMessage.BAD_CONFIG, ErrorTitle.ERROR, buttonCollection);
            alert.addEventListener(Event.CLOSE, function (event:Event):void
            {
                if (event.data.label == "Reset")
                    _appController.particleSystemController.resetParticleSystem();
            });
            return true;
        }

        //
        // Save Config
        //

        public function saveConfig():void
        {
            _appModel.commandExecutor.pushMethod(doSaveConfig);
        }

        private function doSaveConfig():Boolean
        {
            if (_appModel.particleModel.particleDirectory == null)
                return true;
            var config:Object = {};
            config.particleDirectory = _appModel.particleModel.particleDirectory.nativePath;
            if (_appModel.particleModel.appendFromObject != null)
                config.appendFromObject = _appModel.particleModel.appendFromObject;
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(JSON.stringify(config));
            var fileSaveCommandData:FileSaveCommandData = new FileSaveCommandData();
            fileSaveCommandData.bytesToWrite = bytes;
            fileSaveCommandData.fileToSaveTo = File.applicationStorageDirectory.resolvePath("config.json");
            _appModel.commandExecutor.pushCommand(new FileSaveCommand(fileSaveCommandData));
            return true;
        }
    }
}