tableextension 50101 "Warehouse Setup" extends "Warehouse Setup"
{
    fields
    {

        field(50100; "App Location"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
            Caption = 'SGA App Location', Comment = 'ESP=Almacén Aplicación SGA';
        }

        //Parametros
        field(50200; "Usar Lote Proveedor"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Vendor Lot No', Comment = 'ESP=Usar Nº. Lote Proveedor';
        }

        field(50202; "Usar paquetes"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Package', Comment = 'ESP=Usar Paquete';

        }

        field(50203; "Lote Interno Obligatorio"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Mandatory Lot No', Comment = 'ESP=Nº. Lote Obligatorio';
        }

        field(50204; "Usar Serie Proveedor"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Use Vendor Serial No', Comment = 'ESP=Usar Nº. Serie del Proveedor';
        }

        field(50205; "Lote Automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Lot No', Comment = 'ESP=Nº. Lote Automático';

        }
        field(50206; "Serie Automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Serial No', Comment = 'ESP=Nº. Serie Automático';

        }
        field(50207; "Serie Interno Obligatorio"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Mandatory Serial No', Comment = 'ESP=Nº. Serie Obligatorio';
        }

        /*field(50203; "Lanzar Almacenamiento"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Launch automatic Put-Away', Comment = 'ESP=Lanzar automáticamente Almacenamiento';

        }*/

        field(50212; "Ver Recepcion"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Receipt', Comment = 'ESP=Recepción';
        }
        field(50213; "Ver Salidas"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Shipments', Comment = 'ESP=Salidas';
        }
        field(50214; "Ver Inventario"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Inventory', Comment = 'ESP=Inventario';
        }
        field(50215; "Ver Movimientos"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'See Movements', Comment = 'ESP=Movimientos';
        }

        //INVENTARIO APP 
        /*field(50220; AppInvJournalTemplateName; Code[20])
        {
            TableRelation = "Warehouse Journal Template";
            Caption = 'Journal Template', Comment = 'ESP=Diario';
        }
        field(50221; AppInvJournalBatchName; Code[20])
        {
            TableRelation = "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName));
            Caption = 'Journal Batch', Comment = 'ESP=Sección';
        }
        field(50222; SumarCantidad; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Add quantity in inventory', Comment = 'ESP=Incrementar Cantidades';
        }*/

        //RECLASIFICACION
        /*field(50225; AppJournalTemplateName; Code[20])
        {
            TableRelation = "Warehouse Journal Template";
            Caption = 'Journal Template', Comment = 'ESP=Diario';

        }
        field(500226; AppJournalBatchName; Code[20])
        {
            TableRelation = "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppJournalTemplateName));
            Caption = 'Journal Batch', Comment = 'ESP=Sección';

        }*/

        // Envíos y recepciones
        field(50230; "Cantidad envio a cero"; Boolean)
        {
            Caption = 'Reset Shipment quantity', Comment = 'ESP=Crear Envíos sin cantidad';
        }
        field(50231; "Cantidad recepcion a cero"; Boolean)
        {
            Caption = 'Reset Receipt quantity', Comment = 'ESP=Crear Recepciones sin cantidad';
        }

        field(50240; "Numero Serie Inventario"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
            Caption = 'Inventory No Serial', Comment = 'ESP=Nº Serie Inventario';

        }
    }

}