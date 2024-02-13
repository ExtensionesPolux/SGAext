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

        //INVENTARIO APP 
        field(50020; "Almacen Avanzado"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Advanced Warehouse', Comment = 'ESP=Almacén Avanzado';
        }

        field(50021; AppInvJournalTemplateName; Code[20])
        {
            Caption = 'Journal Template', Comment = 'ESP=Diario';
            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Template"
            else
            "Item Journal Template";
        }

        field(50022; AppInvJournalBatchName; Code[20])
        {
            Caption = 'Journal Batch', Comment = 'ESP=Sección';

            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName))
            else
            "Item Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName));
        }

        field(50023; SumarCantidad; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Add quantity in inventory', Comment = 'ESP=Incrementar Cantidades';
        }


    }
}