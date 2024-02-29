page 50108 Inventarios
{
    ApplicationArea = All;
    Caption = 'Inventory', comment = 'ESP="Inventario"';
    PageType = List;
    SourceTable = Inventario;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(NumInventario; Rec.NumInventario)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin field.';
                }
                field(Bin; Rec.Bin)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin field.';
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ItemNo field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Family; Rec.Family)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Family field.';
                }
                field(Subfamily; Rec.Subfamily)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subfamily field.';
                }
                field(LotNo; Rec.LotNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LotNo field.';
                }
                field(SerialNo; Rec.SerialNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SerialNo field.';
                }
                field(PackageNo; Rec.PackageNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PackageNo field.';
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field(QuantityRead; Rec.QuantityRead)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the QuantityRead field.';
                }
                field(Read; Rec.Read)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Read field.';
                }
                field(Resource; Rec.Resource)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resource field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Revised; Rec.Revised)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Revised field.';
                }



            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Generar)
            {
                ApplicationArea = All;

                trigger OnAction();
                var

                begin




                end;

            }
            action(Archivar)
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    RecInventario: Record Inventario;
                    RecInventarioHistorico: Record InventarioHistorico;
                begin
                    IF NOT DIALOG.CONFIRM('Va a archivar el inventario ' + Rec.NumInventario + ' ¿Desea continuar?', FALSE) THEN ERROR('Proceso cancelado');

                    CLEAR(RecInventario);
                    RecInventario.SETRANGE(NumInventario, Rec.NumInventario);
                    IF RecInventario.FINDSET THEN BEGIN
                        REPEAT
                            RecInventarioHistorico.INIT();
                            RecInventarioHistorico.TRANSFERFIELDS(RecInventario);
                            RecInventarioHistorico."Entry No." := 0;
                            RecInventarioHistorico.INSERT();
                        UNTIL RecInventario.NEXT = 0;
                        RecInventario.DELETEALL();
                    END;

                end;

            }
        }
    }
}
