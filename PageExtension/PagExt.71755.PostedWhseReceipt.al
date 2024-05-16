pageextension 71755 "Posted Whse. Receipt" extends "Posted Whse. Receipt"
{
    layout
    {
        addfirst(factboxes)
        {


            part(AlertaRegFactBox; AlertaRegFactBox)
            {
                ApplicationArea = All;
                Caption = 'Alerta';
                Provider = PostedWhseRcptLines;
                SubPageLink = "No." = FIELD("No."), "Line No." = FIELD("Line No.");

            }
        }

    }
}