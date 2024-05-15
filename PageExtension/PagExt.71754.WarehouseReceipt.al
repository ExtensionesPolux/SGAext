pageextension 71754 "Warehouse Receipt" extends "Warehouse Receipt"
{
    layout
    {
        addfirst(factboxes)
        {


            part(AlertaFactBox; AlertaFactBox)
            {
                ApplicationArea = All;
                Caption = 'Alerta';
                Provider = WhseReceiptLines;
                SubPageLink = "No." = FIELD("No."), "Line No." = FIELD("Line No.");

            }
        }

    }
}