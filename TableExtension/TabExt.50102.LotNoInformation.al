tableextension 50102 "Lot No Information" extends "Lot No. Information"
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

        field(50007; NSerie; code[20])
        {
            Caption = 'Serie No.', Comment = 'ESP=Nº serie';
        }

        field(50008; CantidadInicial; Decimal)
        {
            Caption = 'Initial Qty', Comment = 'ESP=Cantidad inicial';
        }
        field(50009; Proveedor; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor', Comment = 'ESP=Proveedor';
        }

    }


    var
        myInt: Integer;
}