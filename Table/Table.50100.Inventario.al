table 50100 Inventario
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(10; NumInventario; Code[50])
        {
            DataClassification = ToBeClassified;

            CaptionML = ENU = 'Inventory',
                        ESP = 'Inventario';
        }
        field(20; Bin; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Bin',
                        ESP = 'Ubicación';
        }
        field(30; ItemNo; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Item No',
                        ESP = 'Referencia';
        }
        field(40; Description; Text[250])
        {
            CaptionML = ENU = 'Description',
                        ESP = 'Descripción';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(item.Description where("No." = field(ItemNo)));
        }
        field(50; Family; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Family',
                        ESP = 'Familia';
        }
        field(60; Subfamily; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Subfamily',
                        ESP = 'Subfamilia';
        }
        field(70; LotNo; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Lot No.',
                        ESP = 'Nº Lote';
        }
        field(75; SerialNo; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Serial No.',
                        ESP = 'Nº Lote';
        }
        field(80; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Quantity',
                        ESP = 'Cantidad';
        }
        field(90; QuantityRead; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Read Quantity',
                        ESP = 'Cantidad Leída';
        }
        field(100; Read; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Read',
                        ESP = 'Leído';
        }
        field(110; "Posting Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Posting Date',
                        ESP = 'Fecha Registro';
        }
        field(120; Resource; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Resource',
                        ESP = 'Recurso';
        }
        field(130; Name; Text[250])
        {
            CaptionML = ENU = 'Name',
                        ESP = 'Nombre';

            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Resource.Name where("No." = field(Resource)));

        }

        field(140; Revised; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Revised',
                        ESP = 'Revisado';
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}