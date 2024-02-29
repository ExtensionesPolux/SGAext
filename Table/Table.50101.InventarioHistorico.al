table 50101 InventarioHistorico
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
            Caption = 'Inventory', comment = 'ESP="Inventario"';

        }
        field(20; Bin; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Bin', comment = 'ESP="Ubicación"';
        }
        field(30; ItemNo; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No', comment = 'ESP="Referencia"';
        }
        field(40; Description; Text[250])
        {
            Caption = 'Description', comment = 'ESP="Descripción"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(item.Description where("No." = field(ItemNo)));
        }
        field(50; Family; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Family', comment = 'ESP="Familia"';
        }
        field(60; Subfamily; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Subfamily', comment = 'ESP="Subfamilia"';
        }
        field(70; LotNo; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Lot No.', comment = 'ESP="Nº Lote"';
        }
        field(80; SerialNo; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Serial No.', comment = 'ESP="Nº Serie"';

        }
        field(90; PackageNo; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Package No.', comment = 'ESP="Nº Paquete"';

        }
        field(100; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity', comment = 'ESP="Cantidad"';
        }
        field(110; QuantityRead; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Read Quantity', comment = 'ESP="Cantidad Leída"';

        }
        field(120; Read; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Read', comment = 'ESP="Leído"';

        }
        field(130; "Posting Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Date', comment = 'ESP="Fecha Registro"';

        }
        field(140; Resource; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Resource', comment = 'ESP="Recurso"';
        }
        field(150; Name; Text[250])
        {
            Caption = 'Name', comment = 'ESP="Nombre"';


            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Resource.Name where("No." = field(Resource)));

        }

        field(160; Revised; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Revised', comment = 'ESP="Revisado"';
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