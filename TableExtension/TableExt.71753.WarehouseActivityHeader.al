tableextension 71753 "Warehouse Activity Header" extends "Warehouse Activity Header"
{
    fields
    {
        field(71740; "Resource No"; Code[20])
        {
            Caption = 'Resource No.', comment = 'ESP="Recurso"';
            TableRelation = Resource."No.";
        }

    }

}