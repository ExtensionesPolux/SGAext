page 50103 "AlertaFactBox"
{
    Caption = 'Alertas';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Lot No. Information";

    layout
    {
        area(Content)
        {
            field(Foto; Rec.Foto)
            {
                ApplicationArea = All;
            }
        }
    }
}