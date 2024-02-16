tableextension 50103 Item extends Item
{
    fields
    {
        /*field(50000; "Usar Caducidad"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Expiration', Comment = 'ESP=Usar Caducidad';
        }*/
        field(50001; "Lot No Serial"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
            Caption = 'Lot No Serial', Comment = 'ESP=Nº Serie Lote';

        }
    }
}