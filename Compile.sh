DIRECTORY="~/Git/BasePlugins-"
FILENAME="Base-Plugins-Plus"

cp $DIRECTORY/scripting/include/* ~/Git/SourceModScripting/include/
~/Git/SourceModScripting/spcomp $DIRECTORY/scripting/$FILENAME.sp -o$DIRECTORY/plugins/$FILENAME.smx
