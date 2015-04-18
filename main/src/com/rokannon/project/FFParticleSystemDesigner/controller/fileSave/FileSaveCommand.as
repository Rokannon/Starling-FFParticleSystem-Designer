package com.rokannon.project.FFParticleSystemDesigner.controller.fileSave
{
    import com.rokannon.core.command.CommandBase;

    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    public class FileSaveCommand extends CommandBase
    {
        private const _fileStream:FileStream = new FileStream();
        private var _data:FileSaveCommandData;

        public function FileSaveCommand(data:FileSaveCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            try
            {
                _fileStream.open(_data.fileToSaveTo, FileMode.WRITE);
                _data.bytesToWrite.position = 0;
                _fileStream.writeBytes(_data.bytesToWrite, 0, _data.bytesToWrite.length);
                _fileStream.close();
            }
            catch (error:Error)
            {
                onFailed();
            }
            onComplete();
        }
    }
}