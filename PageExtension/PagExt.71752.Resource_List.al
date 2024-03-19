pageextension 71752 ResourceList_App extends "Resource List"
{
    layout
    {
        addafter(Type)
        {
            field("Dispositivo Movil"; rec."Dispositivo Movil")
            {
                ApplicationArea = all;
                Editable = False;
            }
        }
    }

}