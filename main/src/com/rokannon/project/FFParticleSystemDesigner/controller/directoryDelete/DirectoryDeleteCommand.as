package com.rokannon.project.FFParticleSystemDesigner.controller.directoryDelete
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.Event;
    import flash.events.IOErrorEvent;

    public class DirectoryDeleteCommand extends CommandBase
    {
        private var _data:DirectoryDeleteCommandData;

        public function DirectoryDeleteCommand(data:DirectoryDeleteCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _data.directoryToDelete.addEventListener(Event.COMPLETE, onDeleteComplete);
            _data.directoryToDelete.addEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            _data.directoryToDelete.deleteDirectoryAsync(_data.deleteDirectoryContents);
        }

        private function onDeleteError(event:IOErrorEvent):void
        {
            _data.directoryToDelete.removeEventListener(Event.COMPLETE, onDeleteComplete);
            _data.directoryToDelete.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            onFailed();
        }

        private function onDeleteComplete(event:Event):void
        {
            _data.directoryToDelete.removeEventListener(Event.COMPLETE, onDeleteComplete);
            _data.directoryToDelete.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            onComplete();
        }
    }
}