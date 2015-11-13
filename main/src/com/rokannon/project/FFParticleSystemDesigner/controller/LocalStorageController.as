package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.command.directoryDelete.DirectoryDeleteCommand;
    import com.rokannon.command.directoryDelete.DirectoryDeleteContext;
    import com.rokannon.command.fileCopy.FileCopyCommand;
    import com.rokannon.command.fileCopy.FileCopyContext;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;
    import com.rokannon.project.FFParticleSystemDesigner.model.params.SetupLocalStorageParams;

    import feathers.controls.Alert;
    import feathers.data.ListCollection;

    import flash.desktop.NativeApplication;
    import flash.filesystem.File;

    import starling.events.Event;

    public class LocalStorageController
    {
        private var _appModel:ApplicationModel;
        private var _appView:ApplicationView;
        private var _appController:ApplicationController;

        public function LocalStorageController()
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
        // Setup Local Storage
        //

        public function setupLocalStorage(handleErrors:Boolean, overwrite:Boolean):void
        {
            var setupLocalStorageParams:SetupLocalStorageParams = new SetupLocalStorageParams();
            setupLocalStorageParams.handleErrors = handleErrors;
            setupLocalStorageParams.overwrite = overwrite;
            _appModel.commandExecutor.pushMethod(doSetupLocalStorage, true, setupLocalStorageParams);
            if (!handleErrors)
                _appModel.commandExecutor.pushMethod(_appController.resetError, false);
        }

        private function doSetupLocalStorage(setupLocalStorageParams:SetupLocalStorageParams):Boolean
        {
            var defaultConfigFile:File = File.applicationDirectory.resolvePath("default_config.json");
            if (!defaultConfigFile.exists)
                return false;
            var demoParticleDirectory:File = File.applicationDirectory.resolvePath("demo_particle");
            if (!demoParticleDirectory.exists)
                return false;
            var configFile:File = File.applicationStorageDirectory.resolvePath("config.json");
            _appModel.firstRun = !configFile.exists || configFile.modificationDate.time < defaultConfigFile.modificationDate.time;
            if (_appModel.firstRun || setupLocalStorageParams.overwrite)
            {
                var fileCopyContext:FileCopyContext;
                fileCopyContext = new FileCopyContext();
                fileCopyContext.directoryToCopyTo = File.applicationStorageDirectory;
                fileCopyContext.fileToCopy = defaultConfigFile;
                fileCopyContext.newFileName = "config.json";
                fileCopyContext.overwrite = true;
                _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyContext));

                var directoryToDelete:File = File.applicationStorageDirectory.resolvePath("demo_particle");

                var directoryDeleteContext:DirectoryDeleteContext = new DirectoryDeleteContext();
                directoryDeleteContext.directoryToDelete = directoryToDelete;
                directoryDeleteContext.failOnError = false;
                _appModel.commandExecutor.pushCommand(new DirectoryDeleteCommand(directoryDeleteContext));

                fileCopyContext = new FileCopyContext();
                fileCopyContext.directoryToCopyTo = File.applicationStorageDirectory;
                fileCopyContext.fileToCopy = demoParticleDirectory;
                fileCopyContext.newFileName = null;
                fileCopyContext.overwrite = true;
                _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyContext));
            }
            if (setupLocalStorageParams.handleErrors)
                _appModel.commandExecutor.pushMethod(handleSetupError, false);
            return true;
        }

        private function handleSetupError():Boolean
        {
            _appModel.commandExecutor.removeAllCommands();
            var buttonCollection:ListCollection = new ListCollection([{label: "Exit"}]);
            var alert:Alert = Alert.show(ErrorMessage.APPLICATION_FOLDER_CORRUPTED, ErrorTitle.FATAL_ERROR,
                buttonCollection);
            alert.addEventListener(Event.CLOSE, function (event:Event):void
            {
                NativeApplication.nativeApplication.exit();
            });
            return true;
        }
    }
}