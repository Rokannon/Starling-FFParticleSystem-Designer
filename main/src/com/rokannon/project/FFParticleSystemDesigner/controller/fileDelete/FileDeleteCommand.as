package com.rokannon.project.FFParticleSystemDesigner.controller.fileDelete
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.Event;
    import flash.events.IOErrorEvent;

    public class FileDeleteCommand extends CommandBase
    {
        private var _data:FileDeleteCommandData;

        public function FileDeleteCommand(data:FileDeleteCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _data.fileToDelete.addEventListener(Event.COMPLETE, onDeleteComplete);
            _data.fileToDelete.addEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            _data.fileToDelete.deleteFileAsync();
        }

        private function onDeleteError(event:IOErrorEvent):void
        {
            _data.fileToDelete.removeEventListener(Event.COMPLETE, onDeleteComplete);
            _data.fileToDelete.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            onFailed();
        }

        private function onDeleteComplete(event:Event):void
        {
            _data.fileToDelete.removeEventListener(Event.COMPLETE, onDeleteComplete);
            _data.fileToDelete.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            onComplete();
        }
    }
}