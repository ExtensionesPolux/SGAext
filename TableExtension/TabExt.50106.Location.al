tableextension 50106 Location extends Location
{
    fields
    {

        field(50010; "Almacenamiento automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Put-Away', comment = 'ESP="Almacenamiento automático"';

        }
        field(50011; "Zona Recepcionados"; code[20])
        {
            Caption = 'Received Zone', comment = 'ESP="Zona Alm. Automático"';
            TableRelation = Zone.Code;
            trigger OnValidate()
            var
            begin
                "Ubicacion Recepcionados" := '';
            end;
        }
        field(50012; "Ubicacion Recepcionados"; code[20])
        {
            Caption = 'Received Bin', comment = 'ESP="Ubicación Alm. Automático"';
            TableRelation = Bin.Code where("Zone Code" = field("Zona Recepcionados"));
        }

    }
}