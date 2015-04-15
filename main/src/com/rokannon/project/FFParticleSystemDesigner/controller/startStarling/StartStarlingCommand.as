package com.rokannon.project.FFParticleSystemDesigner.controller.startStarling
{
    import com.rokannon.core.command.CommandBase;
    import com.rokannon.project.FFParticleSystemDesigner.*;

    import starling.core.Starling;
    import starling.events.Event;

    public class StartStarlingCommand extends CommandBase
    {
        private var _starlingInstance:Starling;
        private var _data:StartStarlingCommandData;

        public function StartStarlingCommand(data:StartStarlingCommandData)
        {
            _data = data;
        }

        override protected function onStart():void
        {
            _starlingInstance = new Starling(StarlingRoot, _data.nativeStage);
            _starlingInstance.addEventListener(Event.ROOT_CREATED, onRootCreated);
            _starlingInstance.start();
        }

        private function onRootCreated(event:Event):void
        {
            _starlingInstance.removeEventListener(Event.ROOT_CREATED, onRootCreated);
            _starlingInstance.showStats = _data.showStats;
            var starlingRoot:StarlingRoot = _starlingInstance.root as StarlingRoot;
            starlingRoot.startApplication(_data.appModel, _data.appController);
            onComplete();
        }
    }
}