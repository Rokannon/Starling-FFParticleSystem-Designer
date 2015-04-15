package com.rokannon.project.FFParticleSystemDesigner.controller.directoryListing
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.FileListEvent;
    import flash.events.IOErrorEvent;

    public class DirectoryListingCommand extends CommandBase
    {
        private var _data:DirectoryListingCommandData;

        public function DirectoryListingCommand(data:DirectoryListingCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _data.fileModel.directoryListing.length = 0;
            _data.directoryToLoad.addEventListener(FileListEvent.DIRECTORY_LISTING, onListingComplete);
            _data.directoryToLoad.addEventListener(IOErrorEvent.IO_ERROR, onListingError);
            _data.directoryToLoad.getDirectoryListingAsync();
        }

        private function onListingError(event:IOErrorEvent):void
        {
            _data.directoryToLoad.removeEventListener(FileListEvent.DIRECTORY_LISTING, onListingComplete);
            _data.directoryToLoad.removeEventListener(IOErrorEvent.IO_ERROR, onListingError);
            onFailed();
        }

        private function onListingComplete(event:FileListEvent):void
        {
            _data.directoryToLoad.removeEventListener(FileListEvent.DIRECTORY_LISTING, onListingComplete);
            _data.directoryToLoad.removeEventListener(IOErrorEvent.IO_ERROR, onListingError);
            for (var i:int = 0; i < event.files.length; ++i)
                _data.fileModel.directoryListing.push(event.files[i]);
            onComplete();
        }
    }
}