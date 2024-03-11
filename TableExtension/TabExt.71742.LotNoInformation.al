tableextension 71742 "Lot No Information" extends "Lot No. Information"
{
    fields
    {
        field(71740; "Fecha Recepcion"; Date)
        {
            Caption = 'Receipt Date', Comment = 'ESP=Fecha Recepción';
            DataClassification = ToBeClassified;
        }
        field(71741; "Lote Proveedor"; Text[50])
        {
            Caption = 'Vendor Lot', Comment = 'ESP=Lote Proveedor';
            DataClassification = ToBeClassified;
        }
        field(71742; "Albaran Proveedor"; Text[50])
        {
            Caption = 'Vendor Shipment No.', Comment = 'ESP=Nº Albarán Proveedor';
            DataClassification = ToBeClassified;
        }
        field(71743; "En Alerta"; Boolean)
        {
            Caption = 'On Alert', Comment = 'ESP=En Alerta';
            DataClassification = ToBeClassified;
        }

        field(71744; "Alerta"; Text[250])
        {
            Caption = 'Alert', Comment = 'ESP=Alerta';
        }
        field(71745; Foto; Media)
        {
            Caption = 'Photo', Comment = 'ESP=Foto';
        }

        field(71746; NSerie; code[20])
        {
            Caption = 'Serie No.', Comment = 'ESP=Nº serie';
        }

        field(71747; CantidadInicial; Decimal)
        {
            Caption = 'Initial Qty', Comment = 'ESP=Cantidad inicial';
        }
        field(71748; Proveedor; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor', Comment = 'ESP=Proveedor';
        }

    }
}