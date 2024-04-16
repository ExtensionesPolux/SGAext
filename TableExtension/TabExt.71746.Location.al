tableextension 71746 Location extends Location
{
    fields
    {

        field(71740; "Almacenamiento automatico"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Put-Away', comment = 'ESP="Almacenamiento automático"';

        }
        field(71471; "Zona Recepcionados"; code[20])
        {
            Caption = 'Received Zone', comment = 'ESP="Zona Alm. Automático"';
            TableRelation = Zone.Code;
            trigger OnValidate()
            var
            begin
                "Ubicacion Recepcionados" := '';
            end;
        }
        field(71742; "Ubicacion Recepcionados"; code[20])
        {
            Caption = 'Received Bin', comment = 'ESP="Ubicación Alm. Automático"';
            TableRelation = Bin.Code where("Zone Code" = field("Zona Recepcionados"));
        }

        //INVENTARIO APP 
        field(71750; "Almacen Avanzado"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Advanced Warehouse', Comment = 'ESP=Almacén Avanzado';
        }

        field(71751; AppInvJournalTemplateName; Code[20])
        {
            Caption = 'Journal Template', Comment = 'ESP=Diario';
            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Template"
            else
            "Item Journal Template";
        }

        field(71752; AppInvJournalBatchName; Code[20])
        {
            Caption = 'Journal Batch', Comment = 'ESP=Sección';

            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName))
            else
            "Item Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName));
        }

        field(71753; SumarCantidad; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Add quantity in inventory', Comment = 'ESP=Incrementar Cantidades';
        }

        //RECLASIFICACION
        field(71760; AppJournalTemplateName; Code[20])
        {

            Caption = 'Journal Template', Comment = 'ESP=Diario';
            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Template"
            else
            "Item Journal Template";

        }
        field(71761; AppJournalBatchName; Code[20])
        {
            TableRelation =
            if ("Almacen Avanzado" = const(true)) "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppJournalTemplateName))
            else
            "Item Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName));
            Caption = 'Journal Batch', Comment = 'ESP=Sección';

        }

        field(71765; "Tiene Ubicaciones"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist(Bin where("Location Code" = field(Code)));
        }



        //DIARIO ALMACEN
        field(71766; AppWhseJournalTemplateName; Code[20])
        {

            Caption = 'Warehouse Journal Template', Comment = 'ESP=Diario Almacén';
            TableRelation = "Warehouse Journal Template";

        }
        field(71767; AppWhseJournalBatchName; Code[20])
        {
            TableRelation = "Warehouse Journal Batch".Name where("Journal Template Name" = FIELD(AppJournalTemplateName));
            Caption = 'Warehouse Journal Batch', Comment = 'ESP=Sección  Almacén';

        }

        //DIARIO PRODUCTO
        field(71768; AppItemJournalTemplateName; Code[20])
        {

            Caption = 'Item Journal Template', Comment = 'ESP=Diario Producto';
            TableRelation = "Item Journal Template";

        }
        field(71769; AppItemJournalBatchName; Code[20])
        {
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = FIELD(AppInvJournalTemplateName));
            Caption = 'Item Journal Batch', Comment = 'ESP=Sección Producto';

        }

    }



}