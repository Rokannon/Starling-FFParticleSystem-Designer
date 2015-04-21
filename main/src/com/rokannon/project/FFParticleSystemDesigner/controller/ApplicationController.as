package com.rokannon.project.FFParticleSystemDesigner.controller
{
    import com.rokannon.core.command.enum.CommandState;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;

    import de.flintfabrik.starling.display.FFParticleSystem;

    public class ApplicationController
    {
        public const configController:ConfigController = new ConfigController();
        public const localStorageController:LocalStorageController = new LocalStorageController();
        public const particleSystemController:ParticleSystemController = new ParticleSystemController();

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
            particleSystemController.connect(_appModel, _appView, this);
        }

        public function startApplication():Boolean
        {
            _appModel.commandExecutor.eventExecuteStart.add(_appView.lockButtons);
            _appModel.commandExecutor.eventExecuteEnd.add(_appView.unlockButtons);
            if (_appModel.commandExecutor.isExecuting)
                _appView.lockButtons();

            FFParticleSystem.init(4096, false, 4096, 16);

            _appModel.commandExecutor.pushMethod(localStorageController.setupLocalStorage, null, false);
            _appModel.commandExecutor.pushMethod(configController.loadConfig, CommandState.COMPLETE);
            _appModel.commandExecutor.pushMethod(particleSystemController.loadParticleSystem, CommandState.COMPLETE);

            return true;
        }
    }
}