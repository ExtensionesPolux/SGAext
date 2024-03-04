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
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Date field.';
                }
                field(NumInventario; Rec.NumInventario)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NumInventario field.';
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field.';
                }
                field(Zone; Rec.Zone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Zone field.';
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
                field(TipoTrack; Rec.TipoTrack)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the TipoTrack field.';
                }
                field(TrackNo; Rec.TrackNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the TrackNo field.';
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
                    RecWarehouseSetup: Record "Warehouse Setup";
                    RecLocation: Record Location;
                    lLocation: Text;
                    MiPaginaModal: Page "Filtro Inventario";

                    cuNoSeriesManagement: Codeunit NoSeriesManagement;
                    cuWS: Codeunit WsApplicationStandard;
                    iTipoTrack: Integer;

                    RecInventarioAux: Record Inventario;
                    Contador: Integer;
                    RecContenedores: Record "Lot No. Information";
                    RecLotNoInf: Record "Lot No. Information";
                    RecItem: Record Item;

                    QueryLotInventoryBin: Query "Lot Numbers by Bin";
                    QueryLotInventory: Query "Lot Numbers by Location";

                    NumInvenatio: Text;

                    Respuesta: Boolean;
                    lbDatosSinRegistrar: Label 'There is unrecorded data. do you wish to continue?', Comment = 'ESP=Hay datos sin registrar. ¿Desea continuar?';
                    lblErrorNSerieInventario: Label 'A serial number has not been defined to generate the inventory', comment = 'ESP=No se ha definido un nº de serie para generar el inventario';

                begin

                    RecWarehouseSetup.Get();
                    if (RecWarehouseSetup."Numero Serie Inventario" = '') then Error(lblErrorNSerieInventario);

                    MiPaginaModal.RunModal();
                    lLocation := MiPaginaModal.Valor_Almacen();
                    //Message(lLocation);

                    Clear(RecInventarioAux);
                    RecInventarioAux.SetRange(Read, true);
                    if RecInventarioAux.FindSet() then begin
                        Respuesta := Confirm(lbDatosSinRegistrar);
                        if not Respuesta then exit;
                    end;

                    Clear(RecInventarioAux);
                    IF RecInventarioAux.FindSet() THEN
                        RecInventarioAux.DeleteAll();

                    NumInvenatio := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Numero Serie Inventario", WorkDate, true);

                    RecLocation.Get(lLocation);
                    RecLocation.CalcFields(RecLocation."Tiene Ubicaciones");
                    if (RecLocation."Tiene Ubicaciones") then begin
                        Clear(QueryLotInventoryBin);
                        QueryLotInventoryBin.SetFilter(QueryLotInventoryBin.Location_Code, '=%1', lLocation);
                        QueryLotInventoryBin.SetFilter(QueryLotInventoryBin.Sum_Qty_Base, '>0');

                        QueryLotInventoryBin.Open();
                        WHILE QueryLotInventoryBin.READ DO BEGIN

                            Rec.Init();

                            Rec."Entry No." := Contador;
                            Rec.NumInventario := NumInvenatio;
                            Rec."Create Date" := Today;
                            Rec.Location := QueryLotInventoryBin.Location_Code;
                            Rec.Zone := QueryLotInventoryBin.Zone_Code;
                            Rec.Bin := QueryLotInventoryBin.Bin_Code;
                            Rec.ItemNo := QueryLotInventoryBin.Item_No;
                            Rec.LotNo := QueryLotInventoryBin.Lot_No;
                            Rec.SerialNo := QueryLotInventoryBin.Serial_No;
                            Rec.Description := cuWS.Descripcion_ItemNo(Rec.ItemNo);
                            REc.Quantity := QueryLotInventoryBin.Sum_Qty_Base;

                            iTipoTrack := cuWS.TipoSeguimientoProducto(QueryLotInventoryBin.Item_No);

                            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
                            case iTipoTrack of
                                0:
                                    begin
                                        Rec.TrackNo := '';
                                        Rec.TipoTrack := 'I';
                                    end;
                                2, 3, 5, 6:
                                    begin
                                        Rec.TrackNo := QueryLotInventoryBin.Serial_No;
                                        Rec.TipoTrack := 'S';
                                    end;
                                1, 4:
                                    begin
                                        Rec.TrackNo := QueryLotInventoryBin.Lot_No;
                                        Rec.TipoTrack := 'L';
                                    end;
                            end;


                            Rec.Insert();
                            Contador += 10;

                        end;

                        QueryLotInventoryBin.Close();
                    end else begin

                        Clear(QueryLotInventory);
                        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, '=%1', lLocation);
                        QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty, '>0');

                        QueryLotInventory.Open();
                        WHILE QueryLotInventory.READ DO BEGIN

                            Rec.Init();

                            Rec.NumInventario := NumInvenatio;
                            Rec."Entry No." := Contador;
                            Rec."Create Date" := Today;
                            Rec.Location := QueryLotInventory.Location_Code;
                            Rec.ItemNo := QueryLotInventory.Item_No;
                            Rec.LotNo := QueryLotInventory.Lot_No;
                            Rec.SerialNo := QueryLotInventory.Serial_No;
                            Rec.Description := cuWS.Descripcion_ItemNo(Rec.ItemNo);
                            REc.Quantity := QueryLotInventory.Sum_Qty;

                            iTipoTrack := cuWS.TipoSeguimientoProducto(QueryLotInventory.Item_No);

                            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
                            case iTipoTrack of
                                0:
                                    begin
                                        Rec.TrackNo := '';
                                        Rec.TipoTrack := 'I';
                                    end;
                                2, 3, 5, 6:
                                    begin
                                        Rec.TrackNo := QueryLotInventory.Serial_No;
                                        Rec.TipoTrack := 'S';
                                    end;
                                1, 4:
                                    begin
                                        Rec.TrackNo := QueryLotInventory.Lot_No;
                                        Rec.TipoTrack := 'L';
                                    end;

                            end;


                            Rec.Insert();
                            Contador += 10;

                        end;

                        QueryLotInventory.Close();


                    end;

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
