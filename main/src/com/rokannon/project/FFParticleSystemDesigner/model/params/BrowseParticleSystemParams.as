package com.rokannon.project.FFParticleSystemDesigner.model.params
{
    import com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse.DirectoryBrowseCommand;

    import flash.filesystem.File;

    public class BrowseParticleSystemParams
    {
        public var handleErrors:Boolean;
        public var directoryBrowseCommand:DirectoryBrowseCommand;
        public var particleDirectory:File;
    }
}