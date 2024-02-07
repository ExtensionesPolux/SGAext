tableextension 50105 SerialNoInformation extends "Serial No. Information"
{
    fields
    {
        field(50001; "Fecha Recepcion"; Date)
        {
            Caption = 'Receipt Date', Comment = 'ESP=Fecha Recepción';
            DataClassification = ToBeClassified;
        }
        field(50002; "Lote Proveedor"; Text[50])
        {
            Caption = 'Vendor Lot', Comment = 'ESP=Lote Proveedor';
            DataClassification = ToBeClassified;
        }
        field(50003; "Albaran Proveedor"; Text[50])
        {
            Caption = 'Vendor Shipment No.', Comment = 'ESP=Nº Albarán Proveedor';
            DataClassification = ToBeClassified;
        }
        field(50004; "En Alerta"; Boolean)
        {
            Caption = 'On Alert', Comment = 'ESP=En Alerta';
            DataClassification = ToBeClassified;
        }

        field(50005; "Alerta"; Text[250])
        {
            Caption = 'Alert', Comment = 'ESP=Alerta';
        }
        field(50006; Foto; Media)
        {
            Caption = 'Photo', Comment = 'ESP=Foto';
        }





    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}