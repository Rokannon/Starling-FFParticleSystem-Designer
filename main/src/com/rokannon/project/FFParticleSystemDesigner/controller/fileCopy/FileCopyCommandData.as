package com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy
{
    import flash.filesystem.File;

    public class FileCopyCommandData
    {
        public var fileToCopy:File;
        public var directoryToCopyTo:File;
        public var newFileName:String;
        public var overwrite:Boolean;
    }
}