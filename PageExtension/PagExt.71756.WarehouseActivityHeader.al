pageextension 71756 "Warehouse Pick" extends "Warehouse Pick"

{
    layout
    {
        addafter("Assigned User ID")
        {

            field("Resource No"; Rec."Resource No")
            {
                ToolTip = 'Resource No', comment = 'ESP="Número de Recurso"';
                ApplicationArea = all;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}