tableextension 71745 SerialNoInformation extends "Serial No. Information"
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
    }
}