tableextension 71741 "Warehouse Setup" extends "Warehouse Setup" //AVA 20240516
{
    fields
    {

        /*field(71740; "App Location"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
            Caption = 'SGA App Location', Comment = 'ESP=Almacén Aplicación SGA';
        }*/

        //Parametros
        field(71741; "Usar Lote Proveedor"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Vendor Lot No', Comment = 'ESP=Usar Nº. Lote Proveedor';
        }

        field(71742; "Lote aut. si proveedor vacio"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Automatic Lot No if empty', Comment = 'ESP=Usar Lote Automático si vacio';

        }

        field(71743; "Lote Interno Obligatorio"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Mandatory Lot No', Comment = 'ESP=Nº. Lote Obligatorio';
        }

        /*field(71744; "Usar Serie Proveedor"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Vendor Serial No', Comment = 'ESP=Usar Nº. Serie del Proveedor';
        }*/

        field(71745; "Lote Automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Lot No', Comment = 'ESP=Nº. Lote Automático';

        }
        /*field(71746; "Serie Automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Serial No', Comment = 'ESP=Nº. Serie Automático';

        }
        field(71747; "Serie Interno Obligatorio"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Mandatory Serial No', Comment = 'ESP=Nº. Serie Obligatorio';
        }*/

        field(71749; "Ver Recepcion"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Receipt', Comment = 'ESP=Recepción';
        }
        field(71750; "Ver Salidas"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Shipments', Comment = 'ESP=Salidas';
        }
        field(71751; "Ver Inventario"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Inventory', Comment = 'ESP=Inventario';
        }
        field(71752; "Ver Movimientos"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Movements', Comment = 'ESP=Movimientos';
        }
        field(71753; "Ver Subcontratacion"; Boolean)
        {
            DataClassification = ToBeClassified;

            Caption = 'See Subcontracting', Comment = 'ESP=Ver Subcontratación';
        }
        field(71754; "Ver Altas"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See New Items Registrations', Comment = 'ESP=Ver Alta Productos';
        }
        field(71755; "Ver Picking Fab"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Manufacturing Picking', Comment = 'ESP=Ver Picking Fabricación';
        }

        // Envíos y recepciones
        field(71760; "Cantidad envio a cero"; Boolean)
        {
            Caption = 'Reset Shipment quantity', Comment = 'ESP=Crear Envíos sin cantidad';
        }
        field(71761; "Cantidad recepcion a cero"; Boolean)
        {
            Caption = 'Reset Receipt quantity', Comment = 'ESP=Crear Recepciones sin cantidad';
        }

        field(71770; "Numero Serie Inventario"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
            Caption = 'Inventory No Serial', Comment = 'ESP=Nº Serie Inventario';
        }

        field(71780; "Numero Serie Paquete"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
            Caption = 'Package No Serial', Comment = 'ESP=Nº Serie Paquete';
        }

        field(71781; "Codigo Sin Paquete"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Without Package Code', Comment = 'ESP=Código Sin Paquete';
        }

        field(71782; "Lote unico por ubicacion"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Single lot per bin', Comment = 'ESP=Lote único por ubicación';

        }
    }

}