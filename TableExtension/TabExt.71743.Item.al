tableextension 71743 Item extends Item
{
    fields
    {
        field(71740; "Lot No Serial"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
            Caption = 'Lot No Serial', Comment = 'ESP=Nº Serie Lote';

        }
    }
}