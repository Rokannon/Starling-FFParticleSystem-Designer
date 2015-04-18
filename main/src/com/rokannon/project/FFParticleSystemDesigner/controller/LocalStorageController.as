package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.command.enum.CommandState;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete.DirectoryDeleteCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorMessage;
    import com.rokannon.project.FFParticleSystemDesigner.controller.enum.ErrorTitle;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy.FileCopyCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;

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

        public function setupLocalStorage(overwrite:Boolean):void
        {
            _appModel.commandExecutor.pushMethod(function ():Boolean
            {
                doSetupLocalStorage(overwrite);
                return true;
            });
            _appModel.commandExecutor.pushMethod(handleSetupError, CommandState.FAILED);
        }

        private function doSetupLocalStorage(overwrite:Boolean):Boolean
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
                _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData), CommandState.COMPLETE);

                var directoryDeleteCommandData:DirectoryDeleteCommandData = new DirectoryDeleteCommandData();
                directoryDeleteCommandData.deleteDirectoryContents = true;
                directoryDeleteCommandData.directoryToDelete = File.applicationStorageDirectory.resolvePath("demo_particle");
                _appModel.commandExecutor.pushCommand(new DirectoryDeleteCommand(directoryDeleteCommandData),
                    CommandState.COMPLETE);

                fileCopyCommandData = new FileCopyCommandData();
                fileCopyCommandData.directoryToCopyTo = File.applicationStorageDirectory;
                fileCopyCommandData.fileToCopy = demoParticleDirectory;
                fileCopyCommandData.newFileName = null;
                fileCopyCommandData.overwrite = true;
                _appModel.commandExecutor.pushCommand(new FileCopyCommand(fileCopyCommandData), CommandState.COMPLETE);
            }
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
            return false;
        }
    }
}