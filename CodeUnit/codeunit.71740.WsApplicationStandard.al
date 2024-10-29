codeunit 71740 WsApplicationStandard //Cambios 2024.09.10 CAMBIO
{
    #region LOGIN

    procedure Login(xJson: Text): Text
    var
        RecRecursos: Record Resource;
        RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
        c: JsonToken;
        input: JsonObject;
        VJsonObjectLogin: JsonObject;
        VJsonTokenPIN: JsonToken;
        lPIN: Text;
        lLocation: Text;
        VJsonObjectRecurso: JsonObject;
        VJsonArrayRecurso: JsonArray;
        VJsonObjectOTS: JsonObject;
        VJsonArrayOTS: JsonArray;
        VJsonArrayParte: JsonArray;
        VJsonText: Text;
        vAlmacenEncontrado: Boolean;
    begin

        If not VJsonObjectLogin.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lPIN := DatoJsonTexto(VJsonObjectLogin, 'PIN');
        lLocation := DatoJsonTexto(VJsonObjectLogin, 'Location');

        Clear(RecRecursos);
        RecRecursos.SetRange(RecRecursos.Pin, lPIN);

        IF NOT RecRecursos.FindFirst() THEN
            exit(lblErrorRecurso);

        vAlmacenEncontrado := false;

        if lLocation <> '' then begin
            Clear(RecLocation);
            RecLocation.SetRange(RecLocation.Code, lLocation);
            if NOT RecLocation.FindFirst() then
                vAlmacenEncontrado := false
            else
                vAlmacenEncontrado := true;
        end;

        VJsonObjectRecurso.Add('No', RecRecursos."No.");
        VJsonObjectRecurso.Add('Name', RecRecursos.Name);
        VJsonObjectRecurso.Add('Copiar', FormatoBoolean(RecRecursos."Permite Copiar"));
        VJsonObjectRecurso.Add('Regularizar', FormatoBoolean(RecRecursos."Permite Regularizar"));
        VJsonObjectRecurso.Add('Inventario', FormatoBoolean(RecRecursos."Ver cantidad inventario"));
        VJsonObjectRecurso.Add('CambiarPicking', FormatoBoolean(RecRecursos."Permite cambiar picking"));

        RecWarehouseSetup.Get();
        //VJsonObjectRecurso.Add('UsarPaquete', FormatoBoolean(RecWarehouseSetup."Usar paquetes"));
        VJsonObjectRecurso.Add('VerRecepcion', FormatoBoolean(RecWarehouseSetup."Ver Recepcion"));
        VJsonObjectRecurso.Add('VerSubcontratacion', FormatoBoolean(RecWarehouseSetup."Ver Subcontratacion"));
        VJsonObjectRecurso.Add('VerSalidas', FormatoBoolean(RecWarehouseSetup."Ver Salidas"));
        VJsonObjectRecurso.Add('VerInventario', FormatoBoolean(RecWarehouseSetup."Ver Inventario"));
        VJsonObjectRecurso.Add('VerMovimientos', FormatoBoolean(RecWarehouseSetup."Ver Movimientos"));
        VJsonObjectRecurso.Add('VerPickingFab', FormatoBoolean(RecWarehouseSetup."Ver Picking Fab"));
        VJsonObjectRecurso.Add('VerAltas', FormatoBoolean(RecWarehouseSetup."Ver Altas"));
        VJsonObjectRecurso.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));
        VJsonObjectRecurso.Add('UsarLoteProveedor', FormatoBoolean(RecWarehouseSetup."Usar Lote Proveedor"));
        VJsonObjectRecurso.Add('LoteAutomatico', FormatoBoolean(RecWarehouseSetup."Lote Automatico"));

        VJsonObjectRecurso.Add('CodificacionPersonalizada', FormatoBoolean(RecWarehouseSetup."Codificacion Personalizada"));
        VJsonObjectRecurso.Add('DigitosProducto', FormatoNumero(RecWarehouseSetup."Digitos Producto"));
        VJsonObjectRecurso.Add('DigitosEntero', FormatoNumero(RecWarehouseSetup."Digitos Entero"));
        VJsonObjectRecurso.Add('DigitosDecimal', FormatoNumero(RecWarehouseSetup."Digitos Decimal"));
        VJsonObjectRecurso.Add('UbicacionAltas', RecWarehouseSetup."Ubicacion Altas");

        if vAlmacenEncontrado then begin

            RecLocation.CalcFields(RecLocation."Tiene Ubicaciones");
            VJsonObjectRecurso.Add('AlmacenAvanzado', FormatoBoolean(RecLocation."Almacen Avanzado"));
            VJsonObjectRecurso.Add('TieneUbicaciones', FormatoBoolean(RecLocation."Tiene Ubicaciones"));
            VJsonObjectRecurso.Add('Location', RecLocation.Code);
            VJsonObjectRecurso.Add('NombreAlamcen', RecLocation.Name);
            VJsonObjectRecurso.Add('RequiereAlmacenamiento', FormatoBoolean(RecLocation."Require Put-away"));
            VJsonObjectRecurso.Add('RequierePicking', FormatoBoolean(RecLocation."Require Pick"));
            VJsonObjectRecurso.Add('ContRecepciones', FormatoNumero(Contador_Recepciones(lLocation)));
            VJsonObjectRecurso.Add('ContSubcontrataciones', FormatoNumero(Contador_Subcontrataciones(lLocation)));
            VJsonObjectRecurso.Add('ContAlmacenamiento', FormatoNumero(Contador_Trabajos(lLocation, 0)));
            VJsonObjectRecurso.Add('ContPicking', FormatoNumero(Contador_Trabajos(lLocation, 1)));
            VJsonObjectRecurso.Add('ContPickingProd', FormatoNumero(Contador_Trabajos(lLocation, 2)));
            VJsonObjectRecurso.Add('ContInventario', FormatoNumero(Contador_Inventario(lLocation)));
            VJsonObjectRecurso.Add('ContTrabajos', FormatoNumero(Contador_Trabajos(lLocation, 9)));
            VJsonObjectRecurso.Add('ContEnvios', FormatoNumero(Contador_Envios(lLocation)));

        end else begin

            VJsonObjectRecurso.Add('AlmacenAvanzado', FormatoBoolean(false));
            VJsonObjectRecurso.Add('TieneUbicaciones', FormatoBoolean(false));
            VJsonObjectRecurso.Add('Location', '');
            VJsonObjectRecurso.Add('NombreAlamcen', '');
            VJsonObjectRecurso.Add('RequiereAlmacenamiento', FormatoBoolean(false));
            VJsonObjectRecurso.Add('RequierePicking', FormatoBoolean(false));
            VJsonObjectRecurso.Add('ContRecepciones', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContSubcontrataciones', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContAlmacenamiento', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContPicking', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContInventario', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContTrabajos', FormatoNumero(0));
            VJsonObjectRecurso.Add('ContEnvios', FormatoNumero(0));

        end;


        VJsonObjectRecurso.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    #endregion

    #region CONTADORES

    local procedure Contador_Recepciones(xLocation: Text): Integer
    var
        RecWhsReceiptLine: Record "Warehouse Receipt Line";
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
    begin
        Clear(RecWhsReceiptLine);
        RecWhsReceiptLine.SetFilter("Qty. Outstanding", '>%1', 0);
        RecWhsReceiptLine.SetRange("Location Code", xLocation);
        exit(RecWhsReceiptLine.Count());
    end;

    local procedure Contador_Subcontrataciones(xLocation: Text): Integer
    var
        RecPurchaseLine: Record "Purchase Line";
    begin
        Clear(RecPurchaseLine);
        RecPurchaseLine.SetFilter(RecPurchaseLine."Prod. Order No.", '>%1', '');
        RecPurchaseLine.SetRange("Location Code", xLocation);
        exit(RecPurchaseLine.Count());
    end;


    local procedure Contador_Envios(xLocation: Text): Integer
    var
        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
    begin
        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetFilter("Qty. Outstanding", '>%1', 0);
        RecWhsShipmentLine.SetRange("Location Code", xLocation);
        exit(RecWhsShipmentLine.Count());
    end;


    /// <summary>
    /// Contador_Trabajos.
    /// </summary>
    /// <param name="xLocation">Alamcen</param>
    /// <param name="xTipo">0:Almacenamiento 1:Picking 2:Picking Fabricacion 9:Todos</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure Contador_Trabajos(xLocation: Text; xTipo: Integer): Integer
    var
        //RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        Contador: Integer;
    begin
        Contador := 0;

        Clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Location Code", xLocation);
        case xTipo of
            0:
                begin
                    RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Activity Type", RecWarehouseActivityLine."Activity Type"::"Put-away");
                end;
            1:
                begin
                    RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Activity Type", RecWarehouseActivityLine."Activity Type"::Pick);
                    RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Source Document", '<>%1', RecWarehouseActivityLine."Source Document"::"Prod. Consumption");
                end;
            2:
                begin
                    RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Activity Type", RecWarehouseActivityLine."Activity Type"::Pick);
                    RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Source Document", '=%1', RecWarehouseActivityLine."Source Document"::"Prod. Consumption");
                end;
        end;
        //repeat

        //RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
        RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Qty. Outstanding", '>0');
        Contador += RecWarehouseActivityLine.Count();

        exit(Contador);
    end;

    local procedure Contador_Inventario(xLocation: Text): Integer
    var
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecPhyInvetRecordHeader: Record "Phys. Invt. Record Header";
    begin
        //RecWarehouseSetup.Get();

        RecLocation.Get(xLocation);

        if (xLocation = '') then exit(0);

        if (RecLocation."Almacen Avanzado") then begin
            Clear(RecWarehouseJournalLine);
            RecWarehouseJournalLine.SetRange("Location Code", xLocation);
            RecWarehouseJournalLine.SetRange("Journal Template Name", RecLocation.AppInvJournalTemplateName);
            RecWarehouseJournalLine.SetRange("Journal Batch Name", RecLocation.AppInvJournalBatchName);
            exit(RecWarehouseJournalLine.Count());
        end else begin
            Clear(RecPhyInvetRecordHeader);
            RecPhyInvetRecordHeader.SetRange(RecPhyInvetRecordHeader.App, true);
            RecPhyInvetRecordHeader.SetRange("Location Code", xLocation);
            exit(RecPhyInvetRecordHeader.Count());

        end;


    end;




    #endregion

    #region WEB SERVICES LICENCIAS
    procedure WsDescargarAES(): Text
    var
        RecLocation: Record Location;
        VJsonObjectLicencia: JsonObject;
        cuLicencia: Codeunit "SGA License Management";
        vAES: Text;
        VJsonText: Text;
    begin

        vAES := cuLicencia.Vector_AES();
        VJsonObjectLicencia.Add('AES', vAES);

        VJsonObjectLicencia.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsRegistrarDispositivo(xRegistro: Text): Text
    var
        cuLicencia: Codeunit "SGA License Management";
    begin
        exit(cuLicencia.Registro(xRegistro));
    end;

    procedure WsRenovarDispositivo(xRegistro: Text): Text
    var
        cuLicencia: Codeunit "SGA License Management";
    begin
        exit(cuLicencia.Renovar(xRegistro));
    end;

    procedure WsMOTD(xDispositivo: Text): Text
    var
        cuLicencia: Codeunit "SGA License Management";
    begin
        exit(cuLicencia.MOTD(xDispositivo));
    end;

    procedure WsBajaDispositivo(xDispositivo: Text): Text
    var
        cuLicencia: Codeunit "SGA License Management";
    begin
        cuLicencia.Eliminar_Registro_BC(xDispositivo);

        exit('');
    end;

    #endregion


    #region WEB SERVICES

    //Datos Básicos

    procedure WsAlmacenes(): Text
    var
        RecLocation: Record Location;
        VJsonObjectLocation: JsonObject;
        VJsonArrayLocation: JsonArray;

        VJsonText: Text;
    begin

        Clear(RecLocation);
        if RecLocation.FindSet() then begin
            repeat

                VJsonObjectLocation.Add('Location', RecLocation.Code);
                VJsonObjectLocation.Add('Name', RecLocation.Name);

                VJsonArrayLocation.Add(VJsonObjectLocation.Clone());
                clear(VJsonObjectLocation);
            until RecLocation.Next() = 0;

        end;

        VJsonArrayLocation.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    //Subcontratación

    procedure WsSubcontrataciones(xJson: Text): Text
    var
        RecPurchaseHeader: Record "Purchase Header";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectDato: JsonObject;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        lLocation: Text;
        VJsonText: Text;
        iPurchaseHeaderNo: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        iPurchaseHeaderNo := '';
        Clear(RecPurchaseLine);
        RecPurchaseLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        RecPurchaseLine.SetRange("Location Code", lLocation);
        RecPurchaseLine.SetFilter("Prod. Order No.", '<>%1', '');
        RecPurchaseLine.SetFilter("Outstanding Quantity", '>%1', 0);
        if RecPurchaseLine.FindSet() then
            repeat

                if (iPurchaseHeaderNo <> RecPurchaseLine."Document No.") then begin
                    iPurchaseHeaderNo := RecPurchaseLine."Document No.";

                    Clear(RecPurchaseHeader);
                    RecPurchaseHeader.SetFilter(RecPurchaseHeader.Status, '=%1', RecPurchaseHeader.Status::Released);
                    RecPurchaseHeader.SetRange("No.", RecPurchaseLine."Document No.");
                    RecPurchaseHeader.SetFilter("Location Code", lLocation);
                    if RecPurchaseHeader.FindFirst() then begin
                        VJsonObjectReceipts := Objeto_Subcontratacion(RecPurchaseHeader."No.");
                        VJsonArrayReceipts.Add(VJsonObjectReceipts.Clone());
                        clear(VJsonObjectReceipts);
                    end;
                end;

            until RecPurchaseLine.Next() = 0;

        VJsonArrayReceipts.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsRecepcionarContenedorSub(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        jPedidoCompra: Text;
        VJsonText: Text;


    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Previo_Recepcionar_Subcontratacion(VJsonObjectContenedor);


        Objeto_Subcontratacion(jPedidoCompra).WriteTo(VJsonText);
        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);

    end;

    procedure WsEliminarContenedorSub(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jPedidoCompra: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Contenedor_Recepcion_Sub(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Subcontratacion(jPedidoCompra).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsEliminarCantidadRecepcionSub(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jPedidoCompra: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Cantidad_Recepcion_Sub(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Subcontratacion(jPedidoCompra).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsRegistrarRecepcionSub(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jPedidoCompra: Text;
        jLinea: Integer;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Registrar_Recepcion_Sub(jPedidoCompra);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Subcontratacion(jPedidoCompra).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    //Recepciones

    procedure WsRecepciones(xJson: Text): Text
    var
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecWhsReceiptHeader);
        RecWhsReceiptHeader.SetFilter("Document Status", '<>%1', RecWhsReceiptHeader."Document Status"::"Completely Received");
        RecWhsReceiptHeader.SetFilter("Location Code", lLocation);
        if RecWhsReceiptHeader.FindSet() then begin
            repeat

                VJsonObjectReceipts := Objeto_Recepcion(RecWhsReceiptHeader."No.");
                VJsonArrayReceipts.Add(VJsonObjectReceipts.Clone());
                clear(VJsonObjectReceipts);
            until RecWhsReceiptHeader.Next() = 0;

        end;

        VJsonArrayReceipts.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsRecepcionarContenedor(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        jRecepcion: Text;
        VJsonText: Text;


    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Previo_Recepcionar(VJsonObjectContenedor);


        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);
        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);

    end;

    procedure WsEliminarContenedor(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;
        jTipo: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jTipo := DatoJsonTexto(VJsonObjectContenedor, 'Type');

        IF (jTipo = 'T') THEN
            Eliminar_Contenedor_Recepcion_Transferencia(xJson)
        else
            Eliminar_Contenedor_Recepcion(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsEliminarCantidadRecepcion(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Cantidad_Recepcion(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsRegistrarRecepcion(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;
        jLinea: Integer;
        jWorkDate: Date;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLinea := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');
        jWorkDate := DatoJsonDate(VJsonObjectContenedor, 'WorkDate');

        Registrar_Recepcion(jRecepcion, jLinea, jWorkDate);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsContenidoUbicacion(xJson: Text): Text
    var
        RecLocations: Record Location;
        VJsonObjectContenedor: JsonObject;

        jArrayContenidoAux: JsonArray;
        jArrayContenido: JsonArray;
        jToken: JsonToken;
        i: Integer;

        VJsonText: Text;
        jTrackNo: Text;
        jZone: Text;
        jBin: Text;
        jLocation: Text;

        iTipoDato: Code[1];
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        jTrackNoAux: Text;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jTrackNo := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectContenedor, 'Bin');
        jZone := DatoJsonTexto(VJsonObjectContenedor, 'Zone');
        jLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        Clear(RecLocations);
        RecLocations.Get(jLocation);


        if (jTrackNo <> '') then
            iTipoDato := Tipo_Dato(jTrackNo)
        else
            iTipoDato := '';



        RecLocations.CalcFields("Tiene Ubicaciones");
        if RecLocations."Tiene Ubicaciones" then begin

            case iTipoDato of
                'I':
                    begin
                        jArrayContenidoAux := Contenidos_Ubicacion(jTrackNo, jZone, jBin, jLocation, iTipoDato, jTrackNo);
                        for i := 0 to jArrayContenidoAux.Count - 1 do begin
                            jArrayContenidoAux.Get(i, jToken);
                            jArrayContenido.Add(jToken);
                        end;

                    end;
                'L':
                    begin
                        jTrackNoAux := '';
                        Clear(RecLotNo);
                        RecLotNo.SetCurrentKey("Item No.");
                        RecLotNo.SetFilter(Inventory, '>0');
                        RecLotNo.SetRange("Lot No.", jTrackNo);
                        if RecLotNo.FindSet() then begin
                            if (RecLotNo."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecLotNo."Item No.";
                                if RecLotNo.Count > 1 then jTrackNoAux := '';
                                jArrayContenidoAux := Contenidos_Ubicacion(RecLotNo."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                'S':
                    begin
                        jTrackNoAux := '';
                        Clear(RecSerialNo);
                        RecSerialNo.SetCurrentKey("Item No.");
                        RecSerialNo.SetRange("Serial No.", jTrackNo);
                        if RecSerialNo.FindSet() then begin
                            if (RecSerialNo."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecSerialNo."Item No.";
                                jArrayContenidoAux := Contenidos_Ubicacion(RecSerialNo."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                'P':
                    begin
                        jTrackNoAux := '';
                        Clear(RecPackage);
                        RecPackage.SetCurrentKey("Item No.");
                        RecPackage.SetRange("Package No.", jTrackNo);
                        if RecPackage.FindSet() then begin
                            if (RecPackage."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecPackage."Item No.";
                                jArrayContenidoAux := Contenidos_Ubicacion(RecPackage."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                else begin

                    jArrayContenido := Contenidos_Ubicacion('', jZone, jBin, jLocation, iTipoDato, jTrackNo);

                end;

            end;

            jArrayContenido.WriteTo(VJsonText);
            exit(VJsonText);

            //EXIT(Contenidos_Ubicacion(jItemNo, jZone, jBin, jLocation));
        end else begin
            EXIT(Contenidos_Sin_Ubicacion(jTrackNo, jLocation, iTipoDato, jTrackNo));
        end;

    end;

    procedure WsPicking(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;

        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Lineas_Picking(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsAlmacenamiento(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;
        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Lineas_Almacenamiento(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsRegistrarAlmacenamiento(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;
        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jLotNo: Text;
        jNo: Text;
        jBinTo: Text;
        jSerialNo: Text;
        jQuantity: Decimal;
        jLineNoTake: Integer;
        jLineNoPlace: Integer;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'QtyToHandle');

        jBinTo := DatoJsonTexto(VJsonObjectDatos, 'BinTo');

        jNo := DatoJsonTexto(VJsonObjectDatos, 'No');

        jLineNoTake := DatoJsonInteger(VJsonObjectDatos, 'LineNoTake');
        jLineNoPlace := DatoJsonInteger(VJsonObjectDatos, 'LineNoPlace');

        exit(Registrar_Almacenamiento(jNo, jLotNo, jItemNo, jBinTo, jSerialNo, jQuantity, jLineNoTake, jLineNoPlace));

    end;

    procedure WsInventarioTrazabilidad(xJson: Text): Text
    var

        RecLocation: Record Location;

        VJsonObjectDatos: JsonObject;

        VJsonText: Text;

        lTrackNo: Text;
        lLocation: Text;
        lItemNo: Text;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        lLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        exit(Inventario_Trazabilidad(lLocation, lTrackNo, lItemNo));


    end;

    procedure WsEnvios(xJson: Text): Text
    var
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectShipments: JsonObject;
        VJsonArrayShipments: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin

        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecWhsShipmentHeader);
        RecWhsShipmentHeader.SetFilter("Document Status", '<>%1', RecWhsShipmentHeader."Document Status"::"Completely Shipped");
        RecWhsShipmentHeader.SetRange("Location Code", lLocation);
        if RecWhsShipmentHeader.FindSet() then begin
            repeat

                VJsonObjectShipments := Objeto_Envio(RecWhsShipmentHeader."No.");
                VJsonArrayShipments.Add(VJsonObjectShipments.Clone());
                clear(VJsonObjectShipments);
            until RecWhsShipmentHeader.Next() = 0;

        end;

        VJsonArrayShipments.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    procedure WsEnviarContenedor(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lSourceLineNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');
        lItemNo := DatoJsonTexto(VJsonObjectDato, 'Reference');
        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');
        lLotNo := DatoJsonTexto(VJsonObjectDato, 'LotNo');
        lSerialNo := DatoJsonTexto(VJsonObjectDato, 'SerialNo');
        lPackageNo := DatoJsonTexto(VJsonObjectDato, 'PackageNo');
        lSourceNo := DatoJsonTexto(VJsonObjectDato, 'SourceNo');
        lSourceLineNo := DatoJsonInteger(VJsonObjectDato, 'SourceLineNo');


        //Comprobar línea
        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        if RecWhsShipmentLine."Bin Code" <> '' then begin
            //Comprobar que existe stock en la ubicación
            Comprobar_Stock_Ubicacion(lItemNo, lLotNo, lSerialNo, lCantidad, RecWhsShipmentLine."Bin Code");
        end;

        Asignar(lCantidad, lItemNo, lLocation, lLotNo, lSerialNo, lPackageNo, lSourceNo, lSourceLineNo);

        //Modificar cantidad a enviar



        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" + lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;



    procedure WsActualizarEnvio(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');


        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;



    procedure WsEnviarEliminarContenedor(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lEntryNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');
        lEntryNo := DatoJsonInteger(VJsonObjectDato, 'EntryNo');

        Eliminar_De_Envio(lCantidad, lEntryNo);

        //Modificar cantidad a enviar

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" - lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;

    procedure WsEnviarEliminarLineaEnvio(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lEntryNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');

        //Modificar cantidad a enviar

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" - lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;

    procedure WsRegistrarEnvio(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jEnvio: Text;
        jLinea: Integer;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jEnvio := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLinea := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        Registrar_Envio(jEnvio, jLinea);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Envio(jEnvio).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsCrearPicking(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jEnvio: Text;
        jLinea: Integer;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jEnvio := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Crear_Picking(jEnvio);

        EXIT('');


    end;

    procedure WsInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jBin: Text;
        jZone: Text;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNoFilter');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'BinFilter');
        jZone := DatoJsonTexto(VJsonObjectDatos, 'ZoneFilter');

        exit(Inventario_Recurso(jRecurso, jLocation, jZone, jBin, jItemNo));

    end;

    procedure WsAgregarLineaInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;

        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jQuantity: Decimal;

        jItemNoFilter: Text;
        jZoneFilter: Text;
        jBinFilter: Text;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jReferencia := DatoJsonTexto(VJsonObjectDatos, 'Referencia');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');

        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        //jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        jItemNoFilter := DatoJsonTexto(VJsonObjectDatos, 'ItemNoFilter');
        jZoneFilter := DatoJsonTexto(VJsonObjectDatos, 'ZoneFilter');
        jBinFilter := DatoJsonTexto(VJsonObjectDatos, 'BinFilter');
        Validar_Linea_Inventario_Almacen_Avanzado(jTrackNo, jBin, jQuantity, jItemNo, jLocation);

        /*Clear(RecLocation);
        RecLocation.Get(jLocation);
        if RecLocation."Almacen Avanzado" then
            Validar_Linea_Inventario_Almacen_Avanzado(jTrackNo, jBinInv, jQuantity, jItemNo, jLocation)
        ELSE
            Validar_Linea_Inventario_Almacen_Basico(jTrackNo, jBinInv, jQuantity, jItemNo, jLocation);*/

        exit(Inventario_Recurso(jRecurso, jLocation, jZoneFilter, jBinFilter, jItemNoFilter));

    end;

    procedure WsMover(xJson: Text): Text
    var

        RecLocation: Record Location;
        RecWarehouseSetup: Record "Warehouse Setup";
        QueryContPaquete: Query "Lot Numbers by Bin";

        VJsonObjectDatos: JsonObject;

        lContenedor: Text;
        lAlmacen: Text;

        lUbicadionDesde: Text;
        lUbicacionHasta: Text;
        lCantidad: Decimal;
        lResource: Text;
        lItemNo: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        newPackageNo: Text;
        ltipo: Text;
        lTrackNo: Text;
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            Error('Respuesta no valida. Se esperaba un Json');

        lContenedor := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lTipo := DatoJsonTexto(VJsonObjectDatos, 'Tipo');

        lItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        lUbicadionDesde := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');
        lUbicacionHasta := DatoJsonTexto(VJsonObjectDatos, 'BinTo');
        lCantidad := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');
        lResource := DatoJsonTexto(VJsonObjectDatos, 'Resource');
        lAlmacen := DatoJsonTexto(VJsonObjectDatos, 'Location');
        lLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        lSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        lPackageNo := DatoJsonTexto(VJsonObjectDatos, 'PackageNo');


        if (ltipo = 'P') THEN begin

            Clear(QueryContPaquete);
            QueryContPaquete.SetFilter(QueryContPaquete.Location_Code, lAlmacen);
            QueryContPaquete.SetFilter(QueryContPaquete.Package_No, lContenedor);
            QueryContPaquete.SetFilter(QueryContPaquete.Sum_Qty_Base, '>%1', 0);
            QueryContPaquete.Open();
            while QueryContPaquete.READ do begin

                lTrackNo := '';
                if (QueryContPaquete.Lot_No <> '') then lTrackNo := QueryContPaquete.Lot_No;
                if (QueryContPaquete.Serial_No <> '') then lTrackNo := QueryContPaquete.Serial_No;

                Clear(RecLocation);
                RecLocation.Get(lAlmacen);
                if RecLocation."Almacen Avanzado" then
                    AppCreateReclassWarehouse_Avanzado(lAlmacen, lUbicadionDesde, lUbicacionHasta, QueryContPaquete.Sum_Qty_Base, lTrackNo, lResource, QueryContPaquete.Item_No, QueryContPaquete.Lot_No, QueryContPaquete.Serial_No, lContenedor, lContenedor)
                ELSE
                    AppCreateReclassWarehouse(lAlmacen, lUbicadionDesde, lUbicacionHasta, QueryContPaquete.Sum_Qty_Base, lTrackNo, lResource, QueryContPaquete.Item_No, QueryContPaquete.Lot_No, QueryContPaquete.Serial_No, lContenedor, lContenedor);

            end;


        END ELSE BEGIN

            RecWarehouseSetup.Get();
            IF (lPackageNo <> '') then begin
                IF (RecWarehouseSetup."Codigo Sin Paquete" = '') THEN ERROR(lblErrorPaqueteGenerico);

                if (lPackageNo <> RecWarehouseSetup."Codigo Sin Paquete") then
                    newPackageNo := RecWarehouseSetup."Codigo Sin Paquete"
                else
                    newPackageNo := lPackageNo;
            END;
            //Comprobar si se está metiendo en un paquete
            IF Existe_Paquete(lUbicacionHasta) then begin
                newPackageNo := lUbicacionHasta;
                lUbicacionHasta := Ubicacion_Paquete(newPackageNo, lAlmacen);
            end;

            Clear(RecLocation);
            RecLocation.Get(lAlmacen);
            if RecLocation."Almacen Avanzado" then
                AppCreateReclassWarehouse_Avanzado(lAlmacen, lUbicadionDesde, lUbicacionHasta, lCantidad, lContenedor, lResource, lItemNo, lLotNo, lSerialNo, lPackageNo, newPackageNo)
            ELSE
                AppCreateReclassWarehouse(lAlmacen, lUbicadionDesde, lUbicacionHasta, lCantidad, lContenedor, lResource, lItemNo, lLotNo, lSerialNo, lPackageNo, newPackageNo)

        END;
        exit('OK');

    end;

    procedure WsMovimientosAlmacen(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;
        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Movimientos_Almacen(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsRegistrarMovimiento(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;
        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jLotNo: Text;
        jNo: Text;
        jBinTo: Text;
        jBinFrom: Text;
        jSerialNo: Text;
        jQuantity: Decimal;
        jDocumentType: Text;
        jDocumentNo: Text;
        jDocumentLineNo: Integer;
        jLineNoTake: Integer;
        jLineNoPlace: Integer;
        rDocumentType: Enum "Warehouse Activity Document Type";
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        jDocumentType := DatoJsonTexto(VJsonObjectDatos, 'DocumentType');
        jDocumentNo := DatoJsonTexto(VJsonObjectDatos, 'DocumentNo');
        jDocumentLineNo := DatoJsonInteger(VJsonObjectDatos, 'DocumentLineNo');

        jBinTo := DatoJsonTexto(VJsonObjectDatos, 'BinTo');
        jBinFrom := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');

        jNo := DatoJsonTexto(VJsonObjectDatos, 'No');
        jLineNoTake := DatoJsonInteger(VJsonObjectDatos, 'LineNoTake');
        jLineNoPlace := DatoJsonInteger(VJsonObjectDatos, 'LineNoPlace');

        case jDocumentType of
            'Receipt':
                rDocumentType := rDocumentType::Receipt;
            'Shipment':
                rDocumentType := rDocumentType::Shipment;
            'Movement Worksheet':
                rDocumentType := rDocumentType::"Movement Worksheet";
            'Production':
                rDocumentType := rDocumentType::Production;
        end;

        Registrar_Movimiento(jNo, jLineNoTake, jLineNoPlace, rDocumentType, jDocumentNo, jDocumentLineNo, jBinFrom, jBinTo, jQuantity, jItemNo, jLotNo, jSerialNo);

        exit(Movimientos_Almacen('', jLocation));

    end;

    procedure WsRegistrosInventario(xJson: Text): Text
    var
        RecRegistroInventario: Record "Phys. Invt. Record Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectInventory: JsonObject;
        VJsonArrayInventory: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin

        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecRegistroInventario);
        RecRegistroInventario.SetRange("Location Code", lLocation);
        RecRegistroInventario.SetRange(App, true);
        if RecRegistroInventario.FindSet() then begin
            repeat

                VJsonObjectInventory := Objeto_Registro_Inventario(RecRegistroInventario."Order No.", RecRegistroInventario."Recording No.");
                VJsonArrayInventory.Add(VJsonObjectInventory.Clone());
                clear(VJsonObjectInventory);
            until RecRegistroInventario.Next() = 0;

        end;

        VJsonArrayInventory.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsLineasRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jOrderNo: Text;
        jRecordingNo: Integer;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');

        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));
    end;

    procedure WsAgregarLineaRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;
        RecBin: Record Bin;
        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jTrackType: Text;

        jQuantity: Decimal;

        jOrderNo: Text;
        jRecordingNo: Integer;
        jLineNo: Integer;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');

        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        jTrackType := DatoJsonTexto(VJsonObjectDatos, 'TrackType');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        Clear(RecBin);
        RecBin.SetRange("Location Code", jLocation);
        RecBin.SetRange(RecBin.Code, jBin);
        if Not RecBin.FindFirst() then EXIT(StrSubstNo(lblErrorUbicacion, jBin));

        Agregar_Linea_Registro_Inventario(jTrackType, jTrackNo, jBin, jQuantity, jItemNo, jLocation, jOrderNo, jRecordingNo);

        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));


    end;

    procedure WsEliminarLineaRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;
        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";

        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jTrackType: Text;

        jQuantity: Decimal;

        jOrderNo: Text;
        jRecordingNo: Integer;
        jLineNo: Integer;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');
        jLineNo := DatoJsonInteger(VJsonObjectDatos, 'LineNo');

        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", jOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", jRecordingNo);
        RecPhyInvetRecordLine.SetRange("Line No.", jLineNo);
        if RecPhyInvetRecordLine.FindFirst() then begin

            if (RecPhyInvetRecordLine."Recorded Without Order") then
                RecPhyInvetRecordLine.delete()
            else begin
                RecPhyInvetRecordLine.Validate(Quantity, 0);
                RecPhyInvetRecordLine.Validate(RecPhyInvetRecordLine.Recorded, false);
                RecPhyInvetRecordLine.Modify();
            end;
        end;


        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));

    end;

    procedure WsCrearPaquete(): Text
    var
        VJsonObjectPaquete: JsonObject;

        numPaquete: Text;
        vJsonText: Text;
    begin

        numPaquete := Crear_Paquete();

        VJsonObjectPaquete.Add('PackageNo', numPaquete);

        VJsonObjectPaquete.WriteTo(vJsonText);
        exit(vJsonText);
    end;


    #endregion

    #region PAQUETE

    local procedure Crear_Paquete(): Text
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecPackages: Record "Package No. Information";
        cuNoSeriesManagement: Codeunit NoSeriesManagement;
        numPaquete: Text;
    begin
        Clear(RecWarehouseSetup);
        RecWarehouseSetup.Get();

        if (RecWarehouseSetup."Numero Serie Paquete" = '') then error(lblErrorSinSeriePaquete);
        numPaquete := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Numero Serie Paquete", WorkDate, true);

        Clear(RecPackages);
        RecPackages.Init();
        RecPackages."Package No." := numPaquete;
        RecPackages.Insert();

        exit(RecPackages."Package No.");

    end;

    #endregion

    #region NUEVA SISTEMATICA


    procedure WsInformacionContenedor(xJson: Text): Text
    var
        VJsonObjectDatos: JsonObject;
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        RecItem: Record Item;
        jBusqueda: Text;
        jItemNo: Text;
        jLotNo: Text;
        jSerialNo: Text;

        vItemNo: Text;
        vDescription: Text;
        vTrackNo: Text;
        vTipoTrack: Text; //I: Item - S:Serie - L:Lote
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jBusqueda := DatoJsonTexto(VJsonObjectDatos, 'Busqueda');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');

        vItemNo := '';
        vDescription := '';
        vTrackNo := '';
        vTipoTrack := '';

        //Comprobar si es un serie
        Clear(RecSerialNo);
        if (jSerialNo <> '') then
            RecSerialNo.SetRange("Serial No.", jSerialNo)
        else
            RecSerialNo.SetRange("Serial No.", jBusqueda);
        if RecSerialNo.FindFirst() then begin
            vItemNo := RecSerialNo."Item No.";
            vDescription := RecSerialNo.Description;
            vTrackNo := RecSerialNo."Serial No.";
            vTipoTrack := 'S';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        //Comprobar si es un lote
        Clear(RecLotNo);
        if (jLotNo <> '') then
            RecLotNo.SetRange("Lot No.", jSerialNo)
        else
            RecLotNo.SetRange("Lot No.", jBusqueda);
        if (jItemNo <> '') then
            RecLotNo.SetRange("Item No.", jItemNo);
        if RecLotNo.FindFirst() then begin
            vTrackNo := RecLotNo."Lot No.";
            vTipoTrack := 'L';
            IF (RecLotNo.Count() > 1) THEN begin
                vItemNo := '';
                vDescription := '';
            end ELSE begin
                vItemNo := RecLotNo."Item No.";
                vDescription := RecLotNo.Description;
            end;
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", jBusqueda);
        if RecPackage.FindFirst() then begin
            vItemNo := RecPackage."Item No.";
            vDescription := RecPackage.Description;
            vTrackNo := RecPackage."Package No.";
            vTipoTrack := 'P';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        if (jItemNo <> '') then
            jBusqueda := jItemNo;

        vDescription := Sacar_Item(jBusqueda);
        IF (jBusqueda <> '') then begin
            vItemNo := jBusqueda;
            vDescription := vDescription;
            vTrackNo := '';
            vTipoTrack := 'I';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        vItemNo := '';
        vDescription := '';
        vTrackNo := '';
        vTipoTrack := '';
        Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
    end;

    local procedure JsonContenedor(xItemNo: Text; xDescription: Text; xTipoTrack: Text; xTrackNo: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        vTipoSeguimiento: Text;
    begin

        // 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento
        vTipoSeguimiento := '99';
        if xItemNo <> '' then
            vTipoSeguimiento := FORMAT(TipoSeguimientoProducto(xItemNo));

        VJsonObjectContenedor.Add('ItemNo', xItemNo);
        VJsonObjectContenedor.Add('Description', xDescription);
        VJsonObjectContenedor.Add('TrackType', xTipoTrack);
        VJsonObjectContenedor.Add('TrackNo', xTrackNo);
        VJsonObjectContenedor.Add('TrackingType', vTipoSeguimiento);

        VJsonObjectContenedor.WriteTo(VJsonText);

        exit(VJsonText);
    end;


    local procedure Sacar_Item(var xDato: Text): Text;
    var
        RecItem: Record Item;
        vItem: Text;
    begin

        Clear(RecItem);
        RecItem.SetRange("No.", xDato);
        if RecItem.FindFirst() then exit(RecItem.Description);

        vItem := Buscar_Referencia_Cruzada(xDato, '');
        IF (vItem <> '') then begin
            RecItem.Get(vItem);
            xDato := RecItem."No.";
            exit(RecItem.Description);
        end else begin
            xDato := '';
            exit('');
        end;




    end;


    #endregion

    #region MOVIMIENTOS ALMACEN
    procedure Movimientos_Almacen(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectPicking: JsonObject;
        VJsonArrayPicking: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionEnvio: Text;
        lLineNoPlace: Integer;

    begin

        RecWarehouseSetup.get();

        //Clear(RecWarehouseActivityHeader);
        //if xNo <> '' then
        //    RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        //RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        //RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        //if RecWarehouseActivityHeader.findset then begin

        // VJsonObjectPicking.Add('No', RecWarehouseActivityHeader."No.");
        //VJsonObjectPicking.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));
        //VJsonObjectPicking.Add('Type', Format(RecWarehouseActivityHeader.Type));

        //VACIAR CANTIDAD A MANIPULAR
        clear(RecWarehouseActivityLine);
        if xNo <> '' then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", xNo);
        //RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
        RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
        IF RecWarehouseActivityLine.FindSet() THEN
            repeat
                RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
            //RecWarehouseActivityLine.Modify();
            UNTIL RecWarehouseActivityLine.Next() = 0;

        //repeat
        lLineNoPlace := 0;
        clear(RecWarehouseActivityLine);
        //RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
        RecWarehouseActivityLine.SetRange("Location Code", xLocation);
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);
        RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
        if RecWarehouseActivityLine.FindSet() then begin
            repeat

                clear(RecWarehouseActivityLineAux);
                RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityLine."No.");
                RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                RecWarehouseActivityLineAux.SetFilter("Line No.", '>%1', RecWarehouseActivityLine."Line No.");
                RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Place);
                if RecWarehouseActivityLineAux.FindFirst() then begin
                    lUbicacionEnvio := RecWarehouseActivityLineAux."Bin Code";
                    lLineNoPlace := RecWarehouseActivityLineAux."Line No.";
                end;


                VJsonObjectLineas.Add('No', Format(RecWarehouseActivityLine."No."));

                VJsonObjectLineas.Add('LineNoTake', FormatoNumero(RecWarehouseActivityLine."Line No."));
                VJsonObjectLineas.Add('LineNoPlace', FormatoNumero(lLineNoPlace));

                VJsonObjectLineas.Add('SourceNo', RecWarehouseActivityLine."Source No.");
                VJsonObjectLineas.Add('SourceLineNo', RecWarehouseActivityLine."Source Line No.");

                if (RecWarehouseActivityLine."Activity Type" = RecWarehouseActivityLine."Activity Type"::Pick) then begin
                    if (RecWarehouseActivityLine."Source Document" = RecWarehouseActivityLine."Source Document"::"Prod. Consumption") then
                        VJsonObjectLineas.Add('Type', 'Fab')
                    else
                        VJsonObjectLineas.Add('Type', Format(RecWarehouseActivityLine."Activity Type"));
                end else
                    VJsonObjectLineas.Add('Type', Format(RecWarehouseActivityLine."Activity Type"));
                VJsonObjectLineas.Add('SourceType', Format(RecWarehouseActivityLine."Source Type"));
                VJsonObjectLineas.Add('SourceDocument', Format(RecWarehouseActivityLine."Source Document"));

                VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                VJsonObjectLineas.Add('Seguimiento', TipoSeguimientoProducto(RecWarehouseActivityLine."Item No."));

                VJsonObjectLineas.Add('ItemReference', Buscar_Referencia_Cruzada(RecWarehouseActivityLine."Item No.", ''));

                VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));

                VJsonObjectLineas.Add('WarehouseDocument', RecWarehouseActivityLine."Whse. Document No.");
                VJsonObjectLineas.Add('DocumentType', FORMAT(RecWarehouseActivityLine."Whse. Document Type"));
                VJsonObjectLineas.Add('DocumentNo', RecWarehouseActivityLine."Source No.");
                VJsonObjectLineas.Add('DocumentLineNo', RecWarehouseActivityLine."Source Line No.");

                VJsonObjectLineas.Add('BinFrom', RecWarehouseActivityLine."Bin Code");
                VJsonObjectLineas.Add('BinTo', lUbicacionEnvio);
                VJsonObjectLineas.Add('LotNo', RecWarehouseActivityLine."Lot No.");
                VJsonObjectLineas.Add('SerialNo', RecWarehouseActivityLine."Serial No.");
                VJsonObjectLineas.Add('PackageNo', RecWarehouseActivityLine."Package No.");

                /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
                case TipoSeguimientoProducto(RecWarehouseActivityLine."Item No.") of
                    0:
                        begin
                            VJsonObjectLineas.Add('TrackNo', '');
                            VJsonObjectLineas.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectLineas.Add('TrackNo', RecWarehouseActivityLine."Serial No.");
                            VJsonObjectLineas.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectLineas.Add('TrackNo', RecWarehouseActivityLine."Lot No.");
                            VJsonObjectLineas.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));
                VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));

                Clear(RecWarehouseActivityHeader);
                RecWarehouseActivityHeader.SetRange("No.", RecWarehouseActivityLine."No.");
                RecWarehouseActivityHeader.SetRange(Type, RecWarehouseActivityLine."Activity Type");
                if RecWarehouseActivityHeader.FindFirst() then begin
                    if RecWarehouseActivityHeader."Resource No" = '' then
                        VJsonObjectLineas.Add('ResourceNo', '')
                    ELSE
                        VJsonObjectLineas.Add('ResourceNo', RecWarehouseActivityHeader."Resource No");
                end else
                    VJsonObjectLineas.Add('ResourceNo', '');


                VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                clear(VJsonObjectLineas);
            until RecWarehouseActivityLine.Next() = 0;

        end;

        //VJsonObjectPicking.Add('Lines', VJsonArrayLineas.Clone());
        //Clear(VJsonArrayLineas);

        //VJsonArrayPicking.Add(VJsonObjectPicking.Clone());
        //clear(VJsonObjectPicking);

        ///until RecWarehouseActivityHeader.Next() = 0

        //end;

        VJsonArrayLineas.WriteTo(VJsonText);

        exit(VJsonText);

    end;

    #endregion

    #region RECEPCIONES

    local procedure Objeto_Recepcion(xNo: code[20]): JsonObject
    var
        RecWhsReceiptLine: Record "Warehouse Receipt Line";
        RecPurchaseHeader: Record "Purchase Header";
        RecSalesHeader: Record "Sales Header";
        RecItemReference: Record "Item Reference";
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecPurchaseLine: Record "Purchase Line";
        RecComentarios: Record "Warehouse Comment Line";
        RecItem: Record Item;
        RecItemTrackingCode: Record "Item Tracking Code";
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        vQuitarCantidadManipular: Boolean;

        CR: Char;

    begin

        vQuitarCantidadManipular := false;
        RecWarehouseSetup.Get();

        CR := 13;

        clear(RecWhsReceiptHeader);
        RecWhsReceiptHeader.SetRange("No.", xNo);
        if RecWhsReceiptHeader.FindFirst() then;

        //Actualizar_Cantidad_Recibir(RecWhsReceiptHeader."No.");

        Clear(VJsonObjectReceipts);

        VJsonObjectReceipts.Add('No', RecWhsReceiptHeader."No.");
        VJsonObjectReceipts.Add('Date', FormatoFecha(RecWhsReceiptHeader."Posting Date"));
        VJsonObjectReceipts.Add('VendorShipmentNo', RecWhsReceiptHeader."Vendor Shipment No.");
        VJsonObjectReceipts.Add('VendorName', '');
        VJsonObjectReceipts.Add('Return', 'False');
        VJsonObjectReceipts.Add('EsSubcontratacion', 'False');

        /*VJsonObjectReceipts.Add('EstadoRecepcion', Format(RecWhsReceiptHeader."Estado Recepcion"));
        if (RecWhsReceiptHeader."Estado Recepcion" = RecWhsReceiptHeader."Estado Recepcion"::"Recepcion urgente") then
            VJsonObjectReceipts.Add('Urgente', 'true')
        else
            VJsonObjectReceipts.Add('Urgente', 'False');*/

        //Comentarios

        Comentarios := '';
        Clear(RecComentarios);
        RecComentarios.SetRange("Table Name", RecComentarios."Table Name"::"Whse. Receipt");
        RecComentarios.SetRange("No.", RecWhsReceiptHeader."No.");
        //RecComentarios.SetRange(RecComentarios."Tipo Comentario", RecComentarios."Tipo Comentario"::APP);
        if RecComentarios.FindSet(false) then begin
            VJsonObjectReceipts.Add('TieneComentarios', 'true');
            repeat
                Comentarios += RecComentarios.Comment + '-*-';
            until RecComentarios.Next() = 0;
        END ELSE
            VJsonObjectReceipts.Add('TieneComentarios', 'false');

        VJsonObjectReceipts.Add('Comentarios', Comentarios);

        Clear(RecWhsReceiptLine);
        RecWhsReceiptLine.SetRange("No.", RecWhsReceiptHeader."No.");
        if RecWhsReceiptLine.FindSet() then begin

            //Buscar el nombre del proveedor                    
            if RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Purchase Order" then begin
                Clear(RecPurchaseHeader);
                RecPurchaseHeader.SetRange("Document Type", RecPurchaseHeader."Document Type"::Order);
                RecPurchaseHeader.SetRange("No.", RecWhsReceiptLine."Source No.");
                if RecPurchaseHeader.FindFirst() then
                    VJsonObjectReceipts.Replace('VendorName', RecPurchaseHeader."Buy-from Vendor Name");

            end;

            if RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Sales Return Order" then begin
                Clear(RecSalesHeader);
                RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::"Return Order");
                RecSalesHeader.SetRange("No.", RecWhsReceiptLine."Source No.");
                if RecSalesHeader.FindFirst() then
                    VJsonObjectReceipts.Replace('VendorName', RecSalesHeader."Sell-to Customer Name");
                VJsonObjectReceipts.Replace('Return', 'True');
            end;

            repeat

                IF RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Inbound Transfer" THEN begin
                    VJsonObjectLines.Add('Type', 'T');
                    if (RecWhsReceiptLine."Qty. to Receive" = 0) then
                        vQuitarCantidadManipular := true;
                end;
                //Pedido Compra
                IF RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Purchase Order" THEN begin
                    VJsonObjectLines.Add('Type', 'P');
                end;

                VJsonObjectLines.Add('LineNo', RecWhsReceiptLine."Line No.");
                VJsonObjectLines.Add('ProdOrderNo', '');
                VJsonObjectLines.Add('Reference', RecWhsReceiptLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsReceiptLine.Description);
                VJsonObjectLines.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWhsReceiptLine."Item No.")));
                VJsonObjectLines.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));

                VJsonObjectLines.Add('Caducidad', FormatoBoolean(Tiene_caducidad(RecWhsReceiptLine."Item No.")));

                /*Clear(RecItem);
                RecItem.Get(RecWhsReceiptLine."Item No.");
                if (RecItem."Item Tracking Code" <> '') then begin
                    clear(RecItemTrackingCode);
                    RecItemTrackingCode.Get(RecItem."Item Tracking Code");
                    VJsonObjectLines.Add('Caducidad', FormatoBoolean(RecItemTrackingCode."Man. Expir. Date Entry Reqd."));
                end else
                    VJsonObjectLines.Add('Caducidad', FormatoBoolean(false));*/


                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsReceiptLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsReceiptLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToReceive', RecWhsReceiptLine."Qty. to Receive (Base)");// ."Qty. to Receive");

                if (RecWhsReceiptLine."Qty. to Receive (Base)" < RecWhsReceiptLine."Qty. Outstanding (Base)") then begin
                    VJsonObjectLines.Add('Complete', false);
                    if (RecWhsReceiptLine."Qty. to Receive (Base)" > 0) then
                        VJsonObjectLines.Add('Partial', true)
                    else
                        VJsonObjectLines.Add('Partial', false);

                end else begin
                    VJsonObjectLines.Add('Complete', true);
                    VJsonObjectLines.Add('Partial', false);
                end;

                //Se busca si tiene lote predefinido
                /*clear(RecPurchaseLine);
                RecPurchaseLine.SetRange("Document No.", RecWhsReceiptLine."Source No.");
                RecPurchaseLine.SetRange("Line No.", RecWhsReceiptLine."Source Line No.");
                if RecPurchaseLine.FindFirst() then
                    VJsonObjectLines.Add('Preasignado', RecPurchaseLine."Lote preasignado")
                else
                    VJsonObjectLines.Add('Preasignado', 'BAD' + RecWhsReceiptLine."Source No." + '--' + RecPurchaseLine."Lote preasignado");
                */

                Clear(VJsonArrayReservas);
                VJsonArrayReservas := Reservas(RecWhsReceiptLine, vQuitarCantidadManipular);
                VJsonObjectLines.Add('Reservations', VJsonArrayReservas);

                VJsonArrayLines.Add(VJsonObjectLines.Clone());
                clear(VJsonObjectLines);

            until RecWhsReceiptLine.Next() = 0;

            VJsonObjectReceipts.Add('Lines', VJsonArrayLines);

            Clear(VJsonArrayLines);
            Clear(VJsonObjectLines);

        end;


        exit(VJsonObjectReceipts);

    end;

    local procedure Reservas(RecWhseReceiptLine: Record "Warehouse Receipt Line"; xQuitarCantidadManipular: Boolean): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
        vTipo: Code[1];
    begin

        vTipo := '';

        Clear(RecReservationEntry);
        RecReservationEntry.SetRange("Location Code", RecWhseReceiptLine."Location Code");
        RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
        RecReservationEntry.SETRANGE("Source ID", RecWhseReceiptLine."Source No.");

        //Transferencia
        IF RecWhseReceiptLine."Source Document" = RecWhseReceiptLine."Source Document"::"Inbound Transfer" THEN begin
            RecReservationEntry.SETRANGE("Source Prod. Order Line", RecWhseReceiptLine."Source Line No.");
            RecReservationEntry.SETRANGE("Source Type", 5741);
            vTipo := 'T';
        end;
        //Pedido Compra
        IF RecWhseReceiptLine."Source Document" = RecWhseReceiptLine."Source Document"::"Purchase Order" THEN begin
            RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseReceiptLine."Source Line No.");
            vTipo := 'P';

        end;

        RecReservationEntry.SETRANGE("Item No.", RecWhseReceiptLine."Item No.");
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT

                if (xQuitarCantidadManipular) then begin
                    RecReservationEntry.Validate("Qty. to Handle (Base)", 0);
                    RecReservationEntry.Modify();
                end;

                VJsonObjectReservas.Add('Type', vTipo);
                VJsonObjectReservas.Add('LineNo', RecWhseReceiptLine."Line No.");
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('PackageNo', RecReservationEntry."Package No.");

                VJsonObjectReservas.Add('Quantity', FormatoNumero(RecReservationEntry."Quantity (Base)"));
                VJsonObjectReservas.Add('QuantityToHadle', FormatoNumero(RecReservationEntry."Qty. to Handle (Base)"));
                if ((vTipo = 'T') and (RecReservationEntry."Quantity (Base)" > RecReservationEntry."Qty. to Handle (Base)")) then
                    VJsonObjectReservas.Add('Marcar', FormatoBoolean(True))
                else
                    VJsonObjectReservas.Add('Marcar', FormatoBoolean(false));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;

    /*local procedure Actualizar_Cantidad_Recibir(xRecepcion: Text)
    var
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecReservationEntry: Record "Reservation Entry";
        CantidadReservada: Decimal;
    begin

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", xRecepcion);
        IF RecWhseReceiptLine.FINDSET THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
            REPEAT
                CantidadReservada := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
                RecReservationEntry.SETRANGE("Source ID", RecWhseReceiptLine."Source No.");
                RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseReceiptLine."Source Line No.");
                RecReservationEntry.SETRANGE("Item No.", RecWhseReceiptLine."Item No.");
                IF RecReservationEntry.FINDSET THEN
                    REPEAT
                        CantidadReservada := CantidadReservada + RecReservationEntry.Quantity;
                    UNTIL RecReservationEntry.NEXT = 0;

                RecWhseReceiptLine.Validate("Qty. to Receive", CantidadReservada / RecWhseReceiptLine."Qty. per Unit of Measure");// ("Qty. to Receive", CantidadReservada);

                RecWhseReceiptLine.MODIFY();
            UNTIL RecWhseReceiptLine.NEXT = 0;
        end;
    end;*/

    local procedure Previo_Recepcionar(VJsonObjectContenedor: JsonObject)
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;

        cuNoSeriesManagement: Codeunit NoSeriesManagement;

        jTrackNo: Text;
        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        jTotalContenedores: Integer;
        jLoteProveedor: Text;
        //jLotePreasignado: Text;
        jSerie: Text;
        jRecurso: Text;
        NumeracionInicial: Integer;
        i: Integer;
        NumContedor: Text;
        TextoContenedorFinal: Text;
        jTipo: Text;

        jImprimir: Boolean;

        iTipoSeguimiento: Integer;
    begin
        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jTotalContenedores := DatoJsonInteger(VJsonObjectContenedor, 'Quantity');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        //jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');

        jTipo := DatoJsonTexto(VJsonObjectContenedor, 'Type');

        //Si es un pedido de transferenc
        if (jTipo = 'T') then begin

            jTrackNo := DatoJsonTexto(VJsonObjectContenedor, 'TrackNo');

            Recepcionar_Contenedor_Transferencia(jTrackNo, jRecepcion, jUnidades);


        end else begin

            if (jRecurso = '') then Error(lblErrorRecurso);

            //Comprobaciones
            //Referencia
            Existe_Referencia(jReferencia, false);

            RecWarehouseSetup.Get();

            iTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
            case iTipoSeguimiento of
                1, 3, 4, 6://Lote
                    begin
                        if (RecWarehouseSetup."Lote Automatico") then begin
                            RecItem.Get(jReferencia);
                            if (RecItem."Lot Nos." = '') then error(lblErrorNSerieLote);
                        end;

                        for i := 1 to jTotalContenedores do begin

                            TextoContenedorFinal := '';
                            //Base para la creación del Nº Contenedor      
                            if (RecWarehouseSetup."Usar Lote Proveedor") then begin
                                if (jLoteProveedor <> '') then
                                    TextoContenedorFinal := jLoteProveedor
                                else begin
                                    if (RecWarehouseSetup."Lote aut. si proveedor vacio") then
                                        TextoContenedorFinal := cuNoSeriesManagement.GetNextNo(RecItem."Lot Nos.", WorkDate, true)
                                    else
                                        error(lblErrorLoteProveedor);
                                end;
                            end else
                                if (RecWarehouseSetup."Lote Automatico") then
                                    TextoContenedorFinal := cuNoSeriesManagement.GetNextNo(RecItem."Lot Nos.", WorkDate, true);

                            Recepcionar_Contenedor(VJsonObjectContenedor, TextoContenedorFinal, NOT jImprimir, iTipoSeguimiento);

                            NumeracionInicial += 1;

                        end;
                    end;
                else BEGIN
                    Recepcionar_Contenedor(VJsonObjectContenedor, '', NOT jImprimir, iTipoSeguimiento);
                END;
            end;


        end;

    end;

    local procedure Recepcionar_Contenedor(VJsonObjectContenedor: JsonObject; xContenedor: Text; xOmitirImpresion: Boolean; xTipoSeguimiento: Integer)
    var
        RecItem: Record Item;
        RecLote: Record "Lot No. Information";
        RecSerie: Record "Serial No. Information";
        RecWhseReceiptHeader: Record "Warehouse Receipt Header";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecWhseSetup: Record "Warehouse Setup";
        RecResource: Record Resource;
        RecPurchaseHeader: Record "Purchase Header";
        RecPurchaseLine: Record "Purchase Line";

        vNumReserva: Integer;

        jAlbaran: Text;
        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        //jLote: Text;
        jSerie: Text;
        jLoteProveedor: Text;
        jLotePreasignado: Text;
        jImprimir: Boolean;
        jEnAlerta: Boolean;
        jText: Text;
        jFoto: Text;
        jRecurso: Text;
        jMultiSerie: Boolean;
        jFechaCaducidad: Text;
        jPaquete: Text;
        FechaCaducidad: Date;

        vArraySeries: JsonArray;
        vJsonObjectSerie: JsonObject;
        vTokenSerie: JsonToken;

        vEncontrado: Boolean;
        vDiferencia: Integer;
        vDiferenciaActual: Integer;
        vLinea: Integer;

        cuBase64: Codeunit "Base64 Convert";
        cuTempBlob: Codeunit "Temp Blob";
        iStream: InStream;
        oStream: OutStream;
        NombreFoto: Text;

    begin

        RecWhseSetup.GeT();

        //Lectura de datos del Json
        jAlbaran := DatoJsonTexto(VJsonObjectContenedor, 'ShipmentNo');
        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jEnAlerta := DatoJsonBoolean(VJsonObjectContenedor, 'OnAlert');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jFechaCaducidad := DatoJsonTexto(VJsonObjectContenedor, 'ExpirationText');

        jPaquete := DatoJsonTexto(VJsonObjectContenedor, 'PackageNo');


        if (jFechaCaducidad <> '') then begin
            Evaluate(FechaCaducidad, jFechaCaducidad);
        end;



        //Comprobaciones
        //Referencia
        //Existe_Referencia(jReferencia, true);


        //Buscar la línea de recepción
        vEncontrado := false;
        vDiferencia := 99999;
        vLinea := 0;

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.RESET();
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Item No.", jReferencia);
        RecWhseReceiptLine.SETFILTER(RecWhseReceiptLine."Qty. Outstanding", '>=%1', jUnidades);
        IF NOT RecWhseReceiptLine.FindSet() THEN Error(lblErrorLineasCantidad);
        repeat

            //Se busca las lineas que aun tengan cantidad pendiente mayor que la cantidad a recepcionar
            //Entre todas las líneas de la misma referencia se busca la que mejor se ajuste
            IF ((RecWhseReceiptLine."Qty. Outstanding" - RecWhseReceiptLine."Qty. to Receive") >= jUnidades) THEN begin
                vEncontrado := true;

                vDiferenciaActual := (RecWhseReceiptLine."Qty. Outstanding" - RecWhseReceiptLine."Qty. to Receive") - jUnidades;

                if (vDiferenciaActual < vDiferencia) then begin
                    vLinea := RecWhseReceiptLine."Line No.";
                    vDiferencia := vDiferenciaActual;
                END;

            end;
        until ((RecWhseReceiptLine.Next() = 0));



        if (vEncontrado) then begin

            //Añadir Nº Albarán a la cabecera de la recepción
            clear(RecWhseReceiptHeader);
            RecWhseReceiptHeader.SetRange("No.", jRecepcion);
            if not RecWhseReceiptHeader.FindFirst() then Error(StrSubstNo(lblErrorRecepcion, jRecepcion));
            RecWhseReceiptHeader."Vendor Shipment No." := jAlbaran;
            RecWhseReceiptHeader.Modify();

            //Se coge la línea
            clear(RecWhseReceiptLine);
            RecWhseReceiptLine.RESET();
            RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
            RecWhseReceiptLine.SETRANGE("Item No.", jReferencia);
            RecWhseReceiptLine.SETRANGE("Line No.", vLinea);
            if not RecWhseReceiptLine.FindFirst() then Error(lblErrorAlRecepcionar);

            //Poner cantidad
            RecWhseReceiptLine.Validate("Qty. to Receive", RecWhseReceiptLine."Qty. to Receive" + jUnidades);
            RecWhseReceiptLine.MODIFY();

            xTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
            case xTipoSeguimiento of
                0://Sin Seguimiento
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then Error(StrSubstNo(lblErrorCodSeguimiento, jReferencia));
                    end;
                1://Lote
                    begin
                        if (xContenedor = '') then begin
                            xContenedor := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (xContenedor = '') THEN ERROR(lblErrorLote);
                            END;
                        end;
                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                        Crear_Reserva(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                    end;
                2://Serie
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then begin
                            ERROR(lblErrorSegProd);
                        end;
                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                3://Lote y Serie
                    begin
                        if (xContenedor = '') then begin
                            xContenedor := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (xContenedor = '') THEN ERROR(lblErrorLote);
                            END;
                        end;

                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                4://Lote y Paquete
                    begin
                        if (xContenedor = '') then begin
                            xContenedor := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (xContenedor = '') THEN ERROR(lblErrorLote);
                            END;
                        end;

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                        Crear_Reserva(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);

                    end;
                5://Serie y Paquete
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then begin
                            ERROR(lblErrorSegProd);
                        end;
                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                6://Lote, Serie y Paquete
                    begin


                        if (xContenedor = '') then begin
                            xContenedor := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (xContenedor = '') THEN ERROR(lblErrorLote);
                            END;
                        end;

                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);

                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;

            end;


        end;


        IF jEnAlerta THEN BEGIN

            jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
            jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
            RecWhseReceiptLine.Alerta := jText;
            If (jFoto <> '') THEN BEGIN

                NombreFoto := 'A-' + jSerie + '.jpg';

                cuTempBlob.CreateOutStream(oStream);
                cuBase64.FromBase64(jFoto, oStream);

                cuTempBlob.CreateInStream(iStream);
                Clear(RecSerie.Foto);
                RecWhseReceiptLine.Foto.ImportStream(iStream, NombreFoto);

            END;
            RecWhseReceiptLine.Modify();

            /*

            if (jSerie <> '') then begin
                Clear(RecSerie);
                RecSerie.SetRange("Item No.", jReferencia);
                RecSerie.SetRange("Serial No.", jSerie);
                if RecSerie.FindFirst() then begin
                    jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                    jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                    If (jFoto <> '') THEN BEGIN

                        NombreFoto := 'A-' + jSerie + '.jpg';

                        cuTempBlob.CreateOutStream(oStream);
                        cuBase64.FromBase64(jFoto, oStream);

                        cuTempBlob.CreateInStream(iStream);
                        Clear(RecSerie.Foto);
                        RecSerie.Foto.ImportStream(iStream, NombreFoto);

                    END;
                    RecSerie.Alerta := jText;
                    RecSerie.Modify();
                end;
            end else begin
                if (xContenedor <> '') then begin
                    Clear(RecLote);
                    RecLote.SetRange("Item No.", jReferencia);
                    RecLote.SetRange("Lot No.", xContenedor);
                    if RecLote.FindFirst() then begin
                        jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                        jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                        If (jFoto <> '') THEN BEGIN

                            NombreFoto := 'A-' + xContenedor + '.jpg';

                            cuTempBlob.CreateOutStream(oStream);
                            cuBase64.FromBase64(jFoto, oStream);

                            cuTempBlob.CreateInStream(iStream);
                            Clear(RecLote.Foto);
                            RecLote.Foto.ImportStream(iStream, NombreFoto);

                        END;
                        RecLote.Alerta := jText;
                        RecLote.Modify();
                    end;
                end;
            end;

            */
        END;



        //Imprimir etiqueta
        Clear(RecResource);
        RecResource.SetRange("No.", jRecurso);
        IF NOT RecResource.FindFirst() then ERROR(lblErrorRecurso);

        /*if jImprimir and not xOmitirImpresion then
            Imprimir_Componente(RecResource."Printer Name", 1, lReferencia, xContenedor);*/

    end;

    local procedure Recepcionar_Contenedor_Transferencia(xTrackNo: Text; xShipmentNo: Text; xQuantity: Decimal)
    var
        RecWhseReceiptHeader: Record "Warehouse Receipt Header";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecWhseSetup: Record "Warehouse Setup";
        RecReservationEntry: Record "Reservation Entry";


        vTipo: Text;

    begin

        RecWhseSetup.GeT();

        vTipo := Tipo_Dato(xTrackNo);

        Clear(RecWhseReceiptHeader);
        RecWhseReceiptHeader.Get(xShipmentNo);


        if (vTipo = 'I') then begin

            clear(RecWhseReceiptLine);
            RecWhseReceiptLine.RESET();
            RecWhseReceiptLine.SETRANGE("No.", xShipmentNo);
            RecWhseReceiptLine.SETRANGE("Item No.", xTrackNo);
            RecWhseReceiptLine.SETFILTER(RecWhseReceiptLine."Qty. Outstanding", '>=%1', xQuantity);
            IF NOT RecWhseReceiptLine.FindSet() THEN Error(lblErrorLineasCantidad);

            RecWhseReceiptLine.Validate("Qty. to Receive", xQuantity);
            RecWhseReceiptLine.Modify();

        end else begin
            Clear(RecReservationEntry);
            RecReservationEntry.SetRange("Location Code", RecWhseReceiptHeader."Location Code");
            RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
            RecReservationEntry.SETRANGE("Source Type", 5741);
            case vTipo of
                'L':
                    RecReservationEntry.SetRange("Lot No.", xTrackNo);
                'S':
                    RecReservationEntry.SetRange("Serial No.", xTrackNo);
                'P':
                    RecReservationEntry.SetRange("Package No.", xTrackNo);
            end;

            RecReservationEntry.SetFilter("Source Prod. Order Line", '>%1', 0);

            IF RecReservationEntry.FINDSET THEN BEGIN
                REPEAT

                    //RecReservationEntry.SETRANGE("Source Prod. Order Line", RecWhseReceiptLine."Source Line No.");

                    clear(RecWhseReceiptLine);
                    RecWhseReceiptLine.RESET();
                    RecWhseReceiptLine.SETRANGE("No.", xShipmentNo);
                    RecWhseReceiptLine.SETRANGE("Source No.", RecReservationEntry."Source ID");
                    RecWhseReceiptLine.SETRANGE("Line No.", RecReservationEntry."Source Prod. Order Line");
                    RecWhseReceiptLine.SETFILTER(RecWhseReceiptLine."Qty. Outstanding", '>=%1', 0);
                    IF NOT RecWhseReceiptLine.FindSet() THEN Error(lblErrorLineasCantidad);

                    IF (vTipo = 'P') then
                        xQuantity := RecReservationEntry."Quantity (Base)";

                    RecWhseReceiptLine.Validate("Qty. to Receive", (RecWhseReceiptLine."Qty. to Receive" + xQuantity));

                    RecWhseReceiptLine.Modify();

                    RecReservationEntry.Validate("Qty. to Handle (Base)", (RecReservationEntry."Qty. to Handle (Base)" + xQuantity));
                    RecReservationEntry.Modify();

                UNTIL RecReservationEntry.NEXT = 0;
            END;

        END;




    end;


    /*local procedure Vaciar_Cantidad_Recibir(xRecepcion: Text)
    var
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SetRange("No.", xRecepcion);
        if RecWhseReceiptLine.FindSet() then
            repeat
                RecWhseReceiptLine.Validate("Qty. to Receive", 0);
                RecWhseReceiptLine.Modify();
            until RecWhseReceiptLine.Next() = 0;

    end;*/

    local procedure Crear_Lote(xLotNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text; xFechaCaducidad: Date)
    var
        RecLote: Record "Lot No. Information";
        RecItem: Record Item;
    begin

        RecItem.Get(xItemNo);

        Clear(RecLote);
        RecLote.SetRange("Lot No.", xLotNo);
        RecLote.SetRange("Item No.", xItemNo);
        if NOT RecLote.FindFirst() then BEGIN

            RecLote.init;

            RecLote."Item No." := xItemNo;
            RecLote."Lot No." := xLotNo;
            RecLote.Description := RecItem.Description;
            RecLote."Fecha Recepcion" := TODAY();
            RecLote."Albaran Proveedor" := xAlbaran;
            if (xVendorLotNo <> '') then
                RecLote."Lote Proveedor" := xVendorLotNo
            else
                RecLote."Lote Proveedor" := xAlbaran;

            if xFechaCaducidad <> 0D then
                RecLote."Fecha Caducidad" := xFechaCaducidad;


            RecLote.INSERT;

        end;
    end;

    local procedure Crear_Serie(xSerialNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text)
    var
        RecSerie: Record "Serial No. Information";
        RecItem: Record Item;
    begin

        RecItem.Get(xItemNo);

        Clear(RecSerie);
        RecSerie.SetRange("Serial No.", xSerialNo);
        if NOT RecSerie.FindFirst() then BEGIN

            RecSerie.init;

            RecSerie."Item No." := xItemNo;
            RecSerie."Serial No." := xSerialNo;
            RecSerie.Description := RecItem.Description;

            RecSerie."Fecha Recepcion" := TODAY();
            RecSerie."Albaran Proveedor" := xAlbaran;
            if (xVendorLotNo <> '') then
                RecSerie."Lote Proveedor" := xVendorLotNo
            else
                RecSerie."Lote Proveedor" := xAlbaran;

            RecSerie.INSERT;

        end else begin
            ERROR(lblErrorSerialDuplicado);
        end;
    end;

    local procedure Crear_Reserva(xLotNo: Text; xSerialNo: Text; xPackageNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text; xRecWhseReceiptLine: Record "Warehouse Receipt Line"; xTipoSeguimiento: Integer; xFechaCaducidad: Date)
    var
        RecReservationEntry: Record "Reservation Entry";
        vNumReserva: Integer;

    begin
        //Crear la reserva
        Clear(RecReservationEntry);
        if RecReservationEntry.FindLast() then
            vNumReserva := RecReservationEntry."Entry No." + 1
        else
            vNumReserva := 1;
        Clear(RecReservationEntry);

        RecReservationEntry.Init();

        RecReservationEntry."Entry No." := vNumReserva;
        RecReservationEntry.Positive := TRUE;
        RecReservationEntry.validate("Item No.", xItemNo);
        RecReservationEntry."Location Code" := xRecWhseReceiptLine."Location Code";
        RecReservationEntry."Quantity (Base)" := xQuantity;
        RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
        RecReservationEntry."Creation Date" := WORKDATE;
        RecReservationEntry."Source Type" := 39;
        RecReservationEntry."Source Subtype" := 1;
        RecReservationEntry."Source ID" := xRecWhseReceiptLine."Source No.";
        RecReservationEntry."Source Ref. No." := xRecWhseReceiptLine."Source Line No.";
        RecReservationEntry."Expected Receipt Date" := WORKDATE;
        RecReservationEntry."Created By" := USERID;
        RecReservationEntry."Qty. per Unit of Measure" := xRecWhseReceiptLine."Qty. per Unit of Measure";
        RecReservationEntry.Quantity := xQuantity;
        RecReservationEntry."Qty. to Handle (Base)" := xQuantity;
        RecReservationEntry."Qty. to Invoice (Base)" := xQuantity;

        case xTipoSeguimiento of
            0://Sin Seguimiento
                begin
                end;
            1://Lote
                begin
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                end;
            2://Serie
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);

                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial No.";
                end;
            3://Lote y Serie
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);


                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial No.";
                end;
            4://Lote y Paquete
                begin
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Package No.";
                end;
            5://Serie y Paquete
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial and Package No.";
                end;
            6://Lote, Serie y Paquete
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial and Package No.";
                end;
        end;

        if (xFechaCaducidad <> 0D) THEN BEGIN
            RecReservationEntry."Expiration Date" := xFechaCaducidad;
            RecReservationEntry."New Expiration Date" := xFechaCaducidad;
        END;

        RecReservationEntry.INSERT;
    end;

    local procedure Eliminar_Contenedor_Recepcion(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLineNo: Integer;
        jEntryNo: Integer;

        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;

        jLotNo: Text;
        jSerialNo: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');
        jEntryNo := DatoJsonInteger(VJsonObjectContenedor, 'EntryNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Entry No.", jEntryNo);
        IF NOT RecReservationEntry.FindFirst() THEN Error(StrSubstNo(lblErrorLoteInternoNoExiste, ''));

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Line No.", jLineNo);
        IF RecWhseReceiptLine.findfirst THEN begin

            RecWhseReceiptLine.Validate("Qty. to Receive", RecWhseReceiptLine."Qty. to Receive" - RecReservationEntry.Quantity);
            if (RecWhseReceiptLine."Qty. to Receive" < 0) then
                RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
        end;

        RecReservationEntry.Delete();



        //Eliminar el lote si no está en algún pedido de compra preasignado
        /*Clear(RecPurchaseLine);
        RecPurchaseLine.SetRange("Lote preasignado", lContenedor);
        IF NOT RecPurchaseLine.FindFirst() THEN begin
            clear(RecLotNoInf);
            RecLotNoInf.SetRange("Lot No.", lContenedor);
            if RecLotNoInf.FindFirst() then
                RecLotNoInf.Delete();
        end;*/


        /*if (EsSubcontratacion) then begin
            Actualizar_Cantidad_Recibir_Subcontratacion(lRecepcion);
            Objeto_Recepcion_Sub(lRecepcion).WriteTo(VJsonText);
        end else begin
            Actualizar_Cantidad_Recibir(lRecepcion);
            Objeto_Recepcion(lRecepcion).WriteTo(VJsonText);
        end;*/


    end;




    local procedure Eliminar_Contenedor_Recepcion_Transferencia(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLineNo: Integer;
        jEntryNo: Integer;

        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');
        jEntryNo := DatoJsonInteger(VJsonObjectContenedor, 'EntryNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Entry No.", jEntryNo);
        IF NOT RecReservationEntry.FindFirst() THEN Error(StrSubstNo(lblErrorLoteInternoNoExiste, ''));

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Line No.", jLineNo);
        IF RecWhseReceiptLine.findfirst THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", RecWhseReceiptLine."Qty. to Receive" - RecReservationEntry.Quantity);
            if (RecWhseReceiptLine."Qty. to Receive" < 0) then
                RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
        end;

        RecReservationEntry.Validate("Qty. to Handle (Base)", 0);
        RecReservationEntry.Modify();

    end;



    local procedure Eliminar_Cantidad_Recepcion(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLineNo: Integer;
        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin


        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Source ID", jRecepcion);
        RecReservationEntry.SetRange("Source Ref. No.", jLineNo);
        IF RecReservationEntry.FINDSET() THEN RecReservationEntry.DELETEALL();

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Line No.", jLineNo);
        IF RecWhseReceiptLine.findfirst THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
        end;

    end;

    local procedure Registrar_Recepcion(xRecepcion: Text; xLinea: Integer; xFechaTrabajo: Date)
    var          //RecWarehouseSetup: Record "Warehouse Setup";
        pgWR: Page "Warehouse Receipt";
        RecWhseReceiptHeader: Record "Warehouse Receipt Header";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        cuWhsePostReceipt: Codeunit "Whse.-Post Receipt";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
        txtError: Text;

    begin

        Clear(RecWhseReceiptHeader);
        RecWhseReceiptHeader.SetRange("No.", xRecepcion);
        IF RecWhseReceiptHeader.FindFirst() THEN begin
            if (xFechaTrabajo <> 0D) then
                RecWhseReceiptHeader."Posting Date" := xFechaTrabajo
            else
                RecWhseReceiptHeader."Posting Date" := WorkDate();
            RecWhseReceiptHeader.Modify();
        end;

        RecWhseReceiptLine.RESET;
        RecWhseReceiptLine.SETRANGE("No.", xRecepcion);

        if (xLinea > 0) then
            RecWhseReceiptLine.SETRANGE(RecWhseReceiptLine."Line No.", xLinea);

        IF RecWhseReceiptLine.FindSet() THEN BEGIN

            RecLocation.Get(RecWhseReceiptLine."Location Code");
            //Comprobar si está definida las ubicación de recepción en el caso de almacenamiento automático
            if RecLocation."Almacenamiento automatico" then BEGIN
                if RecLocation."Ubicacion Recepcionados" = '' then ERROR('No se ha definido ubicación de recepcionados');
                if RecLocation."Zona Recepcionados" = '' then ERROR('No se ha definido zona de recepcionados');
            END;

            cuWhsePostReceipt.RUN(RecWhseReceiptLine);
            /*if not cuWhsePostReceipt.RUN(RecWhseReceiptLine) then begin
                txtError := GetLastErrorText();
                ERROR(txtError);

            end;*/



            if RecLocation."Almacenamiento automatico" then
                Registrar_Almacenamiento(xRecepcion);

            //Vaciar_Cantidad_Recibir(xRecepcion);

        END ELSE
            Error(lblErrorRegistrar);


    end;

    procedure Registrar_Almacenamiento(xRecepcion: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecRecepRegistradas: Record "Posted Whse. Receipt Header";
        RecLocation: Record Location;
        ZonaRecepcionados: Code[20];
        UbicacionRecepcionados: Code[20];

        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";
        RecBin: Record Bin;
        VJsonObjectDatos: JsonObject;

        lResource: Text;
        txtError: Text;
    begin

        Clear(RecRecepRegistradas);
        RecRecepRegistradas.SetRange(RecRecepRegistradas."Whse. Receipt No.", xRecepcion);
        if NOT RecRecepRegistradas.FindLast() then ERROR('No se ha registrado correctamente la recepción %1', xRecepcion);

        RecLocation.Get(RecRecepRegistradas."Location Code");


        if RecLocation."Ubicacion Recepcionados" = '' then ERROR('No se ha definido ubicación de recepcionados');
        if RecLocation."Zona Recepcionados" = '' then ERROR('No se ha definido zona de recepcionados');

        UbicacionRecepcionados := RecLocation."Ubicacion Recepcionados";
        ZonaRecepcionados := RecLocation."Zona Recepcionados";

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("Whse. Document No.", RecRecepRegistradas."No.");
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
        RecWarehouseActivityLine.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type"::"Put-away");
        if RecWarehouseActivityLine.FindSet() then
            repeat
                //RecWarehouseActivityLine.Resource := lResource;
                RecWarehouseActivityLine.VALIDATE(RecWarehouseActivityLine."Zone Code", ZonaRecepcionados);
                RecWarehouseActivityLine.VALIDATE(RecWarehouseActivityLine."Bin Code", UbicacionRecepcionados);
                RecWarehouseActivityLine.Modify();
            until RecWarehouseActivityLine.Next() = 0;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("Whse. Document No.", RecRecepRegistradas."No.");
        RecWarehouseActivityLine.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type"::"Put-away");
        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine);
        /*IF NOT cuWarehouseActivityRegister.run(RecWarehouseActivityLine) then begin
            txtError := GetLastErrorText();
            ERROR(txtError);
        end;*/

    end;


    /*procedure Crear_Almacenamiento(xReceiptNo: Code[20])
    var
        CreatePutAwayFromWhseSource: Report "Whse.-Source - Create Document";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        HideValidationDialog: Boolean;
    begin

        Commit();

        HideValidationDialog := true;

        PostedWhseRcptLine.SetFilter("Whse. Receipt No.", xReceiptNo);  //Whse. Receipt No.
        PostedWhseRcptLine.SetFilter(Quantity, '>0');
        PostedWhseRcptLine.SetFilter(
          Status, '<>%1', PostedWhseRcptLine.Status::"Completely Put Away");
        if PostedWhseRcptLine.Find('-') then begin
            CreatePutAwayFromWhseSource.SetPostedWhseReceiptLine(PostedWhseRcptLine, '');
            CreatePutAwayFromWhseSource.SetHideValidationDialog(HideValidationDialog);
            CreatePutAwayFromWhseSource.UseRequestPage(not HideValidationDialog);
            CreatePutAwayFromWhseSource.RunModal();
            CreatePutAwayFromWhseSource.GetResultMessage(1);
            Clear(CreatePutAwayFromWhseSource);
        end else
            if not HideValidationDialog then
                Error(lblErrorNadaQueRegistrar);
    end;*/

    #endregion

    #region RECEPCIONES SUBCONTRATACION

    local procedure Objeto_Subcontratacion(xNo: code[20]): JsonObject
    var
        RecPurchaseHeader: Record "Purchase Header";
        RecSalesHeader: Record "Sales Header";
        RecItemReference: Record "Item Reference";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecPurchaseLine: Record "Purchase Line";
        RecComentarios: Record "Warehouse Comment Line";
        RecItem: Record Item;
        RecItemTrackingCode: Record "Item Tracking Code";
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        vQuitarCantidadManipular: Boolean;

        CR: Char;

    begin

        vQuitarCantidadManipular := false;
        RecWarehouseSetup.Get();

        CR := 13;

        Clear(RecPurchaseHeader);
        RecPurchaseHeader.SetRange("Document Type", RecPurchaseHeader."Document Type"::Order);
        RecPurchaseHeader.SetRange("No.", xNo);
        if RecPurchaseHeader.FindFirst() then;

        //Actualizar_Cantidad_Recibir(RecWhsReceiptHeader."No.");

        Clear(VJsonObjectReceipts);

        VJsonObjectReceipts.Add('No', RecPurchaseHeader."No.");

        VJsonObjectReceipts.Add('Date', FormatoFecha(RecPurchaseHeader."Posting Date"));
        VJsonObjectReceipts.Add('VendorShipmentNo', RecPurchaseHeader."Vendor Shipment No.");

        VJsonObjectReceipts.Add('VendorName', RecPurchaseHeader."Buy-from Vendor Name");
        //VJsonObjectReceipts.Add('ProdOrderNo', RecPurchaseLine."Prod. Order No.");
        VJsonObjectReceipts.Add('Name', RecPurchaseHeader."Buy-from Vendor Name");
        VJsonObjectReceipts.Add('Return', 'False');
        VJsonObjectReceipts.Add('EsSubcontratacion', 'True');
        VJsonObjectReceipts.Add('TieneComentarios', 'false');
        VJsonObjectReceipts.Add('Comentarios', '');
        Clear(RecPurchaseLine);
        //RecPurchaseLine.SetRange(RecPurchaseLine."Document Type", RecPurchaseLine."Document Type"::Order);
        RecPurchaseLine.SetRange(RecPurchaseLine."Document No.", xNo);
        RecPurchaseLine.SetRange("Location Code", RecPurchaseHeader."Location Code");
        RecPurchaseLine.SetFilter("Prod. Order No.", '<>%1', '');
        RecPurchaseLine.SetFilter("Outstanding Quantity", '>%1', 0);
        if RecPurchaseLine.FindSet() then begin
            repeat

                if RecPurchaseLine."Prod. Order No." <> '' then begin

                    VJsonObjectLines.Add('LineNo', RecPurchaseLine."Line No.");
                    VJsonObjectLines.Add('ProdOrderNo', RecPurchaseLine."Prod. Order No.");
                    VJsonObjectLines.Add('Reference', RecPurchaseLine."No.");
                    VJsonObjectLines.Add('Description', RecPurchaseLine.Description);

                    CLEAR(RecItem);
                    RecItem.GET(RecPurchaseLine."No.");

                    VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecPurchaseLine."No.", ''));

                    VJsonObjectLines.Add('Outstanding', RecPurchaseLine."Outstanding Quantity");
                    VJsonObjectLines.Add('ToReceive', RecPurchaseLine."Qty. to Receive");

                    if (RecPurchaseLine."Qty. to Receive" < RecPurchaseLine."Outstanding Quantity") then
                        VJsonObjectLines.Add('Complete', false)
                    else
                        VJsonObjectLines.Add('Complete', true);

                    Clear(VJsonArrayReservas);
                    VJsonArrayReservas := Reservas_Subcontratacion(RecPurchaseLine);
                    VJsonObjectLines.Add('Reservations', VJsonArrayReservas);

                    VJsonArrayLines.Add(VJsonObjectLines.Clone());
                    Clear(VJsonObjectLines);

                end;

            until RecPurchaseLine.Next() = 0;

            VJsonObjectReceipts.Add('Lines', VJsonArrayLines);

            Clear(VJsonArrayLines);


        end;


        exit(VJsonObjectReceipts);

    end;

    local procedure Reservas_Subcontratacion(RecPurchaseLine: Record "Purchase Line"): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
    begin

        //Buscar en las reservas de la Orden de Producción
        Clear(RecReservationEntry);
        RecReservationEntry.SETRANGE("Source ID", RecPurchaseLine."Prod. Order No.");
        RecReservationEntry.SETRANGE("Item No.", RecPurchaseLine."No.");
        RecReservationEntry.SetRange(Description, Format(RecPurchaseLine."Line No."));
        RecReservationEntry.SetFilter("Lot No.", '<>%1', '');
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('Quantity', QuitarPunto(format(RecReservationEntry.Quantity)));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;

    local procedure Previo_Recepcionar_Subcontratacion(VJsonObjectContenedor: JsonObject)
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;
        cuNoSeriesManagement: Codeunit NoSeriesManagement;

        jReferencia: Text;
        jTotalContenedores: Integer;
        jLoteProveedor: Text;
        jRecurso: Text;
        BaseNumeroContenedor: Text;
        NumeracionInicial: Integer;
        i: Integer;
        NumContedor: Text;
        TextoContenedorFinal: Text;
        jTipo: Text;

        jImprimir: Boolean;

        iTipoSeguimiento: Integer;
    begin

        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jTotalContenedores := DatoJsonInteger(VJsonObjectContenedor, 'Quantity');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');


        if (jRecurso = '') then Error(lblErrorRecurso);

        //Comprobaciones
        //Referencia
        Existe_Referencia(jReferencia, false);

        RecWarehouseSetup.Get();

        BaseNumeroContenedor := '';
        iTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
        case iTipoSeguimiento of
            1, 3, 4, 6://Lote
                begin
                    if (RecWarehouseSetup."Lote Automatico") then begin
                        RecItem.Get(jReferencia);
                        if (RecItem."Lot Nos." = '') then error(lblErrorNSerieLote);
                    end;
                end;
        end;

        for i := 1 to jTotalContenedores do begin

            TextoContenedorFinal := '';
            case iTipoSeguimiento of
                1, 3, 4, 6://Lote
                    begin
                        if (RecWarehouseSetup."Usar Lote Proveedor") then begin
                            if (jLoteProveedor <> '') then
                                TextoContenedorFinal := jLoteProveedor
                            else begin
                                if (RecWarehouseSetup."Lote aut. si proveedor vacio") then
                                    TextoContenedorFinal := cuNoSeriesManagement.GetNextNo(RecItem."Lot Nos.", WorkDate, true)
                                else
                                    error(lblErrorLoteProveedor);
                            end;
                        end else
                            if (RecWarehouseSetup."Lote Automatico") then
                                TextoContenedorFinal := cuNoSeriesManagement.GetNextNo(RecItem."Lot Nos.", WorkDate, true);
                    end;
            end;

            Recepcionar_Contenedor_Subcontratacion(VJsonObjectContenedor, TextoContenedorFinal, NOT jImprimir, iTipoSeguimiento);

            NumeracionInicial += 1;

        end;

    end;

    local procedure Recepcionar_Contenedor_Subcontratacion(VJsonObjectContenedor: JsonObject; xContenedor: Text; xOmitirImpresion: Boolean; xTipoSeguimiento: Integer)
    var
        RecItem: Record Item;
        RecLote: Record "Lot No. Information";
        RecSerie: Record "Serial No. Information";
        RecWhseSetup: Record "Warehouse Setup";
        RecResource: Record Resource;
        RecPurchaseHeader: Record "Purchase Header";
        RecPurchaseLine: Record "Purchase Line";

        vNumReserva: Integer;

        jAlbaran: Text;
        jReferencia: Text;
        jPedidoCompra: Text;
        jUnidades: Integer;
        jLote: Text;
        jSerie: Text;
        jLoteProveedor: Text;
        jLotePreasignado: Text;
        jImprimir: Boolean;
        jEnAlerta: Boolean;
        jText: Text;
        jFoto: Text;
        jRecurso: Text;
        jMultiSerie: Boolean;
        jFechaCaducidad: Text;
        jPaquete: Text;
        FechaCaducidad: Date;

        vArraySeries: JsonArray;
        vJsonObjectSerie: JsonObject;
        vTokenSerie: JsonToken;

        vEncontrado: Boolean;
        vDiferencia: Integer;
        vDiferenciaActual: Integer;
        vLinea: Integer;

        cuBase64: Codeunit "Base64 Convert";
        cuTempBlob: Codeunit "Temp Blob";
        iStream: InStream;
        oStream: OutStream;
        NombreFoto: Text;

    begin

        RecWhseSetup.GeT();

        //Lectura de datos del Json
        jAlbaran := DatoJsonTexto(VJsonObjectContenedor, 'ShipmentNo');
        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jEnAlerta := DatoJsonBoolean(VJsonObjectContenedor, 'OnAlert');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jFechaCaducidad := DatoJsonTexto(VJsonObjectContenedor, 'ExpirationText');

        jPaquete := DatoJsonTexto(VJsonObjectContenedor, 'PackageNo');

        if (jFechaCaducidad <> '') then begin
            Evaluate(FechaCaducidad, jFechaCaducidad);
        end;


        //Buscar la línea de recepción
        vEncontrado := false;
        vDiferencia := 99999;
        vLinea := 0;

        clear(RecPurchaseLine);
        RecPurchaseLine.RESET();
        RecPurchaseLine.SETRANGE("Document No.", jPedidoCompra);
        RecPurchaseLine.SETRANGE("No.", jReferencia);
        RecPurchaseLine.SETFILTER("Outstanding Quantity", '>=%1', jUnidades);
        IF NOT RecPurchaseLine.FindSet() THEN Error(lblErrorLineasCantidad);
        repeat

            //Se busca las lineas que aun tengan cantidad pendiente mayor que la cantidad a recepcionar
            //Entre todas las líneas de la misma referencia se busca la que mejor se ajuste
            IF ((RecPurchaseLine."Outstanding Quantity" - RecPurchaseLine."Qty. to Receive") >= jUnidades) THEN begin
                vEncontrado := true;

                vDiferenciaActual := (RecPurchaseLine."Outstanding Quantity" - RecPurchaseLine."Qty. to Receive") - jUnidades;

                if (vDiferenciaActual < vDiferencia) then begin
                    vLinea := RecPurchaseLine."Line No.";
                    vDiferencia := vDiferenciaActual;
                END;

            end;
        until ((RecPurchaseLine.Next() = 0));



        if (vEncontrado) then begin

            //Añadir Nº Albarán a la cabecera de la recepción
            clear(RecPurchaseHeader);
            RecPurchaseHeader.SetRange("No.", jPedidoCompra);
            if not RecPurchaseHeader.FindFirst() then Error(StrSubstNo(lblErrorRecepcion, jPedidoCompra));
            RecPurchaseHeader."Vendor Shipment No." := jAlbaran;
            RecPurchaseHeader.Modify();

            //Se coge la línea
            clear(RecPurchaseLine);
            RecPurchaseLine.RESET();
            RecPurchaseLine.SETRANGE("Document No.", jPedidoCompra);
            RecPurchaseLine.SETRANGE("No.", jReferencia);
            RecPurchaseLine.SETRANGE("Line No.", vLinea);
            if not RecPurchaseLine.FindFirst() then Error(lblErrorAlRecepcionar);

            //Poner cantidad
            RecPurchaseLine.Validate("Qty. to Receive", RecPurchaseLine."Qty. to Receive" + jUnidades);
            RecPurchaseLine.MODIFY();

            xTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
            case xTipoSeguimiento of
                0://Sin Seguimiento
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then Error(StrSubstNo(lblErrorCodSeguimiento, jReferencia));
                    end;
                1://Lote
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;
                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                        Crear_Reserva_Sub(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                    end;
                2://Serie
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then begin
                            ERROR(lblErrorSegProd);
                        end;
                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva_Sub('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva_Sub('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                3://Lote y Serie
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;

                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva_Sub(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva_Sub(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                4://Lote y Paquete
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);
                        Crear_Reserva_Sub(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);

                    end;
                5://Serie y Paquete
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then begin
                            ERROR(lblErrorSegProd);
                        end;
                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva_Sub('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva_Sub('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                6://Lote, Serie y Paquete
                    begin


                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;

                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor, FechaCaducidad);

                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        IF (jPaquete = '') THEN jPaquete := RecWhseSetup."Codigo Sin Paquete";

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva_Sub(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva_Sub(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecPurchaseLine, xTipoSeguimiento, FechaCaducidad);
                        end;


                    end;



            end;


        end;


        IF jEnAlerta THEN BEGIN
            if (jSerie <> '') then begin
                Clear(RecSerie);
                RecSerie.SetRange("Item No.", jReferencia);
                RecSerie.SetRange("Serial No.", jSerie);
                if RecSerie.FindFirst() then begin
                    jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                    jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                    If (jFoto <> '') THEN BEGIN

                        NombreFoto := 'A-' + jSerie + '.jpg';

                        cuTempBlob.CreateOutStream(oStream);
                        cuBase64.FromBase64(jFoto, oStream);

                        cuTempBlob.CreateInStream(iStream);
                        Clear(RecSerie.Foto);
                        RecSerie.Foto.ImportStream(iStream, NombreFoto);

                    END;
                    RecSerie.Alerta := jText;
                    RecSerie.Modify();
                end;
            end else begin
                if (xContenedor <> '') then begin
                    Clear(RecLote);
                    RecLote.SetRange("Item No.", jReferencia);
                    RecLote.SetRange("Lot No.", xContenedor);
                    if RecLote.FindFirst() then begin
                        jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                        jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                        If (jFoto <> '') THEN BEGIN

                            NombreFoto := 'A-' + xContenedor + '.jpg';

                            cuTempBlob.CreateOutStream(oStream);
                            cuBase64.FromBase64(jFoto, oStream);

                            cuTempBlob.CreateInStream(iStream);
                            Clear(RecLote.Foto);
                            RecLote.Foto.ImportStream(iStream, NombreFoto);

                        END;
                        RecLote.Alerta := jText;
                        RecLote.Modify();
                    end;
                end;
            end;
        END;

        //Imprimir etiqueta
        Clear(RecResource);
        RecResource.SetRange("No.", jRecurso);
        IF NOT RecResource.FindFirst() then ERROR(lblErrorRecurso);

        /*if jImprimir and not xOmitirImpresion then
            Imprimir_Componente(RecResource."Printer Name", 1, lReferencia, xContenedor);*/

    end;


    local procedure Crear_Reserva_Sub(xLotNo: Text; xSerialNo: Text; xPackageNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text; xRecPurchaseLine: Record "Purchase Line"; xTipoSeguimiento: Integer; xFechaCaducidad: Date)
    var
        RecReservationEntry: Record "Reservation Entry";
        RecProdOrderLine: Record "Prod. Order Line";

        vNumReserva: Integer;

    begin
        //Crear la reserva
        Clear(RecReservationEntry);
        if RecReservationEntry.FindLast() then
            vNumReserva := RecReservationEntry."Entry No." + 1
        else
            vNumReserva := 1;
        Clear(RecReservationEntry);

        Clear(RecProdOrderLine);
        RecProdOrderLine.SetRange("Prod. Order No.", xRecPurchaseLine."Prod. Order No.");
        if not RecProdOrderLine.FindFirst() then ERROR('No se ha encontrado la OP %1', xRecPurchaseLine."Prod. Order No.");

        RecReservationEntry.Init();

        RecReservationEntry."Entry No." := vNumReserva;
        RecReservationEntry.Positive := TRUE;
        RecReservationEntry.validate("Item No.", xItemNo);
        RecReservationEntry."Location Code" := xRecPurchaseLine."Location Code";
        RecReservationEntry."Quantity (Base)" := xQuantity;
        RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
        RecReservationEntry."Creation Date" := WORKDATE;
        RecReservationEntry."Source Type" := 5406;
        RecReservationEntry."Source Subtype" := 3;
        RecReservationEntry."Source ID" := RecProdOrderLine."Prod. Order No.";
        RecReservationEntry."Source Prod. Order Line" := RecProdOrderLine."Line No.";
        RecReservationEntry."Source Ref. No." := 0;
        RecReservationEntry."Expected Receipt Date" := WORKDATE;
        RecReservationEntry."Created By" := USERID;
        RecReservationEntry."Qty. per Unit of Measure" := xRecPurchaseLine."Qty. per Unit of Measure";
        RecReservationEntry.Quantity := xQuantity;
        RecReservationEntry."Qty. to Handle (Base)" := xQuantity;
        RecReservationEntry."Qty. to Invoice (Base)" := xQuantity;

        case xTipoSeguimiento of
            0://Sin Seguimiento
                begin
                end;
            1://Lote
                begin
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                end;
            2://Serie
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);

                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial No.";
                end;
            3://Lote y Serie
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);


                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial No.";
                end;
            4://Lote y Paquete
                begin
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Package No.";
                end;
            5://Serie y Paquete
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial and Package No.";
                end;
            6://Lote, Serie y Paquete
                begin
                    if (xSerialNo = '') then error(lblErrorSerialNoEmpty);
                    if (xLotNo = '') then error(lblErrorLotNoEmpty);
                    if (xPackageNo = '') then error(lblErrorPackageNoEmpty);

                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial and Package No.";
                end;
        end;

        if (xFechaCaducidad <> 0D) THEN BEGIN
            RecReservationEntry."Expiration Date" := xFechaCaducidad;
            RecReservationEntry."New Expiration Date" := xFechaCaducidad;
        END;

        RecReservationEntry.INSERT;
    end;



    local procedure Eliminar_Contenedor_Recepcion_Sub(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecPurchaseLine: Record "Purchase Line";
        RecLotNoInf: Record "Lot No. Information";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jPedidoCompra: Text;
        jLineNo: Integer;
        jEntryNo: Integer;

        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');
        jEntryNo := DatoJsonInteger(VJsonObjectContenedor, 'EntryNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Entry No.", jEntryNo);
        IF NOT RecReservationEntry.FindFirst() THEN Error(StrSubstNo(lblErrorLoteInternoNoExiste, ''));

        clear(RecPurchaseLine);
        RecPurchaseLine.SETRANGE("Document No.", jPedidoCompra);
        RecPurchaseLine.SETRANGE("Line No.", jLineNo);
        IF RecPurchaseLine.findfirst THEN begin
            RecPurchaseLine.Validate("Qty. to Receive", RecPurchaseLine."Qty. to Receive" - RecReservationEntry.Quantity);
            if (RecPurchaseLine."Qty. to Receive" < 0) then
                RecPurchaseLine.Validate("Qty. to Receive", 0);
            RecPurchaseLine.MODIFY();
        end;

        RecReservationEntry.Delete();


        //Eliminar el lote si no está en algún pedido de compra preasignado
        /*Clear(RecPurchaseLine);
        RecPurchaseLine.SetRange("Lote preasignado", lContenedor);
        IF NOT RecPurchaseLine.FindFirst() THEN begin
            clear(RecLotNoInf);
            RecLotNoInf.SetRange("Lot No.", lContenedor);
            if RecLotNoInf.FindFirst() then
                RecLotNoInf.Delete();
        end;*/


        /*if (EsSubcontratacion) then begin
            Actualizar_Cantidad_Recibir_Subcontratacion(lRecepcion);
            Objeto_Recepcion_Sub(lRecepcion).WriteTo(VJsonText);
        end else begin
            Actualizar_Cantidad_Recibir(lRecepcion);
            Objeto_Recepcion(lRecepcion).WriteTo(VJsonText);
        end;*/




    end;

    local procedure Eliminar_Cantidad_Recepcion_Sub(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jPedidoCompra: Text;
        jLineNo: Integer;
        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin


        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jPedidoCompra := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Source ID", jPedidoCompra);
        RecReservationEntry.SetRange("Source Ref. No.", jLineNo);
        IF RecReservationEntry.FINDSET() THEN RecReservationEntry.DELETEALL();

        clear(RecPurchaseLine);
        RecPurchaseLine.SETRANGE("Document No.", jPedidoCompra);
        RecPurchaseLine.SETRANGE("Line No.", jLineNo);
        IF RecPurchaseLine.findfirst THEN begin
            RecPurchaseLine.Validate("Qty. to Receive", 0);
            RecPurchaseLine.MODIFY();
        end;

    end;

    local procedure Registrar_Recepcion_Sub(xPedidoCompra: Text)
    var
        pgWR: Page "Warehouse Receipt";
        RecPurchaseHeader: Record "Purchase Header";
        cuPurchPost: Codeunit "Purch.-Post";
        txtError: Text;
    //RecWarehouseSetup: Record "Warehouse Setup";
    begin
        Clear(RecPurchaseHeader);
        RecPurchaseHeader.SetRange(RecPurchaseHeader."Document Type", RecPurchaseHeader."Document Type"::Order);
        RecPurchaseHeader.SETRANGE(RecPurchaseHeader."No.", xPedidoCompra);


        IF RecPurchaseHeader.FindFirst() THEN BEGIN
            RecPurchaseHeader."Posting Date" := Today;
            RecPurchaseHeader.Modify();
            RecPurchaseHeader.Receive := true;
            cuPurchPost.RUN(RecPurchaseHeader);
            /*IF NOT cuPurchPost.RUN(RecPurchaseHeader) THEN BEGIN
                txtError := GetLastErrorText();
                ERROR(txtError);
            END;*/

            //Vaciar_Cantidad_Recibir_Sub(xRecepcion);

        END ELSE
            Error(lblErrorRegistrar);


    end;



    #endregion

    #region INFORMACION

    procedure Contenidos_Ubicacion(xItemNo: Text; xZone: Text; xBin: Text; xLocation: Text; xTipoDato: Code[1]; xDato: Text): JsonArray
    var

        RecContenedores: Record "Lot No. Information";
        RecLotNoInf: Record "Lot No. Information";
        RecBinContent: Record "Bin Content";
        RecItem: Record Item;

        QueryLotInventory: Query "Lot Numbers by Bin";

        VJsonObjectContenido: JsonObject;
        VJsonArrayContenido: JsonArray;
        VJsonObjectContenedor: JsonObject;
        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        VJsonText: Text;
        xNuevoItem: Text;

        iTipoTrack: Integer;

        iTipoDato: Code[1];
    begin


        Clear(RecBinContent);


        RecBinContent.SetRange("Location Code", xLocation);

        if (xTipoDato = 'L') THEN
            RecBinContent.SetRange(RecBinContent."Lot No. Filter", xDato);
        if (xTipoDato = 'S') THEN
            RecBinContent.SetRange(RecBinContent."Serial No. Filter", xDato);
        if (xTipoDato = 'P') THEN
            RecBinContent.SetRange(RecBinContent."Package No. Filter", xDato);

        if (xItemNo <> '') then begin

            Clear(RecItem);
            RecItem.SetRange("No.", xItemNo);
            if NOT RecItem.FindFirst() THEN begin
                xNuevoItem := Buscar_Referencia_Cruzada(xItemNo, '');
                if (xNuevoItem = '') then Error(StrSubstNo(lblErrorReferencia, xItemNo));

                xItemNo := xNuevoItem;

            end;

            RecBinContent.SetFilter(RecBinContent."Item No.", '=%1', xItemNo);

        end;

        if (xBin <> '') then
            RecBinContent.SetFilter(RecBinContent."Bin Code", '=%1', xBin);

        if (xZone <> '') then
            RecBinContent.SetFilter(RecBinContent."Zone Code", '=%1', xZone);

        RecBinContent.SetFilter(RecBinContent.Quantity, '>0');

        if RecBinContent.findset then begin
            repeat

                RecBinContent.CalcFields(RecBinContent.Quantity);
                VJsonObjectContenido.Add('Zone', RecBinContent."Zone Code");
                VJsonObjectContenido.Add('Bin', RecBinContent."Bin Code");
                VJsonObjectContenido.Add('ItemNo', RecBinContent."Item No.");
                VJsonObjectContenido.Add('Description', Descripcion_ItemNo(RecBinContent."Item No."));
                VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(RecBinContent."Item No.")));
                VJsonObjectContenido.Add('BinInventory', FormatoNumero(RecBinContent.Quantity));

                //Inventario por ubicación
                Clear(QueryLotInventory);
                QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', RecBinContent."Item No.");
                QueryLotInventory.SetFilter(QueryLotInventory.Bin_Code, '=%1', RecBinContent."Bin Code");
                QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty_Base, '>0');

                if (xTipoDato = 'L') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xDato);
                if (xTipoDato = 'S') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xDato);
                if (xTipoDato = 'P') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Package_No, xDato);

                QueryLotInventory.Open();
                WHILE QueryLotInventory.READ DO BEGIN
                    VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
                    VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);

                    iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);

                    case iTipoTrack of
                        0:
                            begin
                                VJsonObjectInventario.Add('TrackNo', '');
                                VJsonObjectInventario.Add('TipoTrack', 'I');
                                VJsonObjectInventario.Add('UseExpiration', FormatoBoolean(False));
                                VJsonObjectInventario.Add('Expiration', FormatoFecha(Caducidad_Mov_Almacen(QueryLotInventory.Item_No, '', '')));
                            end;
                        2, 3, 5, 6:
                            begin
                                VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                                VJsonObjectInventario.Add('TipoTrack', 'S');
                                IF (Tiene_Caducidad(QueryLotInventory.Item_No)) THEN begin
                                    VJsonObjectInventario.Add('UseExpiration', FormatoBoolean(True));
                                    VJsonObjectInventario.Add('Expiration', FormatoFecha(Caducidad_Mov_Almacen(QueryLotInventory.Item_No, '', QueryLotInventory.Serial_No)));
                                end ELSE BEGIN
                                    VJsonObjectInventario.Add('UseExpiration', FormatoBoolean(False));
                                    VJsonObjectInventario.Add('Expiration', FormatoFecha(Caducidad_Mov_Almacen(QueryLotInventory.Item_No, '', '')));
                                END;
                            end;
                        1, 4:
                            begin
                                VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                                VJsonObjectInventario.Add('TipoTrack', 'L');
                                IF (Tiene_Caducidad(QueryLotInventory.Item_No)) THEN begin
                                    VJsonObjectInventario.Add('UseExpiration', FormatoBoolean(True));
                                    VJsonObjectInventario.Add('Expiration', FormatoFecha(Caducidad_Mov_Almacen(QueryLotInventory.Item_No, QueryLotInventory.Lot_No, '')));
                                end ELSE BEGIN
                                    VJsonObjectInventario.Add('UseExpiration', FormatoBoolean(False));
                                    VJsonObjectInventario.Add('Expiration', FormatoFecha(Caducidad_Mov_Almacen(QueryLotInventory.Item_No, '', '')));
                                END;
                            end;

                    end;

                    VJsonObjectInventario.Add('Zone', QueryLotInventory.Zone_Code);
                    VJsonObjectInventario.Add('Bin', QueryLotInventory.Bin_Code);
                    VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty_Base));
                    VJsonObjectInventario.Add('Unit', QueryLotInventory.Unit_of_Measure_Code);

                    VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                    Clear(VJsonObjectInventario);
                END;

                VJsonObjectContenido.Add('Lots', VJsonArrayInventario);

                Clear(VJsonObjectInventario);
                Clear(VJsonArrayInventario);

                QueryLotInventory.Close();

                VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                Clear(VJsonObjectContenido);

            until RecBinContent.Next() = 0;

        end else begin

            VJsonObjectContenido.Add('Zone', '');
            VJsonObjectContenido.Add('Bin', '');
            VJsonObjectContenido.Add('ItemNo', xItemNo);
            VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemNo)));
            VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemNo));
            VJsonObjectContenido.Add('BinInventory', FormatoNumero(0));
            VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
            VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
            Clear(VJsonObjectContenido);
        end;




        //VJsonArrayContenido.WriteTo(VJsonText);
        //exit(VJsonText);

        exit(VJsonArrayContenido);

    end;

    procedure Contenidos_Sin_Ubicacion(xItemNo: Text; xLocation: Text; xTipoDato: Code[1]; xDato: Text): Text
    var

        RecContenedores: Record "Lot No. Information";
        RecLotNoInf: Record "Lot No. Information";
        RecItem: Record Item;

        QueryLotInventory: Query "Lot Numbers by Location 2";

        VJsonObjectContenido: JsonObject;
        VJsonArrayContenido: JsonArray;
        VJsonObjectContenedor: JsonObject;
        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        xItemAnt: Text;

        VJsonText: Text;
        xNuevoItem: Text;

        SumQty: Decimal;
        iTipoTrack: Integer;
    begin

        xItemAnt := '';
        SumQty := 0;

        //Inventario por mov. producto
        Clear(QueryLotInventory);

        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, '=%1', xLocation);

        if (xTipoDato = 'N') THEN
            ERROR(lblErrorTrackNo);
        if (xTipoDato = 'L') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xDato);
        if (xTipoDato = 'S') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xDato);
        if (xTipoDato = 'P') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Package_No, xDato);
        if (xTipoDato = 'I') THEN
            QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', xItemNo);


        QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty, '>0');

        QueryLotInventory.Open();
        WHILE QueryLotInventory.READ DO BEGIN

            if (xItemAnt <> QueryLotInventory.Item_No) then begin

                IF (xItemAnt <> '') THEN begin
                    VJsonObjectContenido.Add('Zone', '');
                    VJsonObjectContenido.Add('Bin', '');
                    VJsonObjectContenido.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(QueryLotInventory.Item_No)));
                    VJsonObjectContenido.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                    VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
                    VJsonObjectContenido.Add('Lots', '');
                    VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                    Clear(VJsonObjectContenido);
                end;

                xItemAnt := QueryLotInventory.Item_No;

                iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);

            end;
            VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
            VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
            VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);

            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
            case iTipoTrack of
                0:
                    begin
                        VJsonObjectInventario.Add('TrackNo', '');
                        VJsonObjectInventario.Add('TipoTrack', 'I');
                    end;
                2, 3, 5, 6:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                        VJsonObjectInventario.Add('TipoTrack', 'S');
                    end;
                1, 4:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                        VJsonObjectInventario.Add('TipoTrack', 'L');
                    end;

            end;


            VJsonObjectInventario.Add('Zone', '');
            VJsonObjectInventario.Add('Bin', '');
            VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty));
            VJsonObjectInventario.Add('Unit', QueryLotInventory.Unit_of_Measure_Code);

            SumQty += QueryLotInventory.Sum_Qty;

            VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
            Clear(VJsonObjectInventario);

        end;

        IF (xItemAnt = '') THEN begin


            if (xTipoDato = 'I') THEN begin

                Clear(RecItem);
                RecItem.SetRange("No.", xItemNo);
                IF RecItem.FindFirst() then begin
                    VJsonObjectContenido.Add('Zone', '');
                    VJsonObjectContenido.Add('Bin', '');
                    VJsonObjectContenido.Add('ItemNo', xItemNo);
                    VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemNo)));
                    VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemNo));
                    VJsonObjectContenido.Add('BinInventory', FormatoNumero(0));
                    VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
                    VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                    Clear(VJsonObjectContenido);
                end else begin
                    VJsonObjectContenido.Add('Zone', '');
                    VJsonObjectContenido.Add('Bin', '');
                    VJsonObjectContenido.Add('ItemNo', xItemAnt);
                    VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemAnt)));
                    VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemAnt));
                    VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
                    VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
                    VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                    Clear(VJsonObjectContenido);
                end;

            end else begin
                VJsonObjectContenido.Add('Zone', '');
                VJsonObjectContenido.Add('Bin', '');
                VJsonObjectContenido.Add('ItemNo', xItemAnt);
                VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemAnt)));
                VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemAnt));
                VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
                VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
                VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                Clear(VJsonObjectContenido);
            end;


        end else begin
            VJsonObjectContenido.Add('Zone', '');
            VJsonObjectContenido.Add('Bin', '');
            VJsonObjectContenido.Add('ItemNo', xItemAnt);
            VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemAnt)));
            VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemAnt));
            VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
            VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
            VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
            Clear(VJsonObjectContenido);
        end;

        QueryLotInventory.Close();


        VJsonArrayContenido.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    #endregion

    #region MOVER


    /// <summary>
    /// Tipo_Trazabilidad.
    /// </summary>
    /// <param name="xTrackNo">Text.</param>
    /// <returns>L:Lote S:Serie P:Paquete N:Nada</returns>
    local procedure Tipo_Trazabilidad(xTrackNo: Text): Code[1]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPaquete: Record "Package No. Information";
        RecItem: Record Item;
    begin
        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit('L');

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit('S');

        Clear(RecPaquete);
        RecPaquete.SetRange("Package No.", xTrackNo);
        if RecPaquete.FindFirst() then exit('P');

        Clear(RecItem);
        RecItem.SetRange("No.", xTrackNo);
        if RecItem.FindFirst() then exit('I');

        exit('N');


    end;


    procedure AppCreateReclassWarehouse_Avanzado(xLocation: Text; xFromBin: code[20]; xToBin: code[20]; xQty: decimal; xTrackNo: code[20]; xResourceNo: code[20]; xItemNo: code[20]; xLotNo: Text; xSerialNo: Text; xPackageNo: Text; newPackageNo: Text);
    var
        RecLocation: Record Location;
        WhseJnlTemplate: record "Warehouse Journal Template";
        WhseJnlLine: record "Warehouse Journal Line";
        WhseJnlLineLast: record "Warehouse Journal Line";
        RecBin: Record Bin;

        WhseItemTrackingLine: record "Whse. Item Tracking Line";
        WhseItemTrackingLineLast: record "Whse. Item Tracking Line";
        LineNo: Integer;

        QueryLotInventory: Query "Lot Numbers by Bin";
        RecWarehouseSetup: Record "Warehouse Setup";

        sTipo: Integer;


        WhseJnlRegisterLine: codeunit "Whse. Jnl.-Register Line";

        txtError: Text;
        lblErrorReclasif: Label 'Not exist Reclassification Template', comment = 'ESP="No existe Libro diario Reclasificación"';
    begin

        Clear(RecLocation);
        RecLocation.Get(xLocation);

        if (RecLocation.AppJournalTemplateName) = '' then Error(lblErrorReclasif);
        if (RecLocation.AppJournalBatchName) = '' then Error(lblErrorReclasif);


        WhseJnlTemplate.reset;
        WhseJnlTemplate.setrange(Type, WhseJnlTemplate.Type::Reclassification);
        if not WhseJnlTemplate.findset then
            error(lblErrorReclasif);

        WhseJnlLine.RESET;
        WhseJnlLine.SETRANGE("Journal Template Name", RecLocation.AppJournalTemplateName);
        WhseJnlLine.SETRANGE("Journal Batch Name", RecLocation.AppJournalBatchName);
        IF WhseJnlLine.findset then
            repeat
                WhseJnlLine.delete;
            until WhseJnlLine.Next = 0;

        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(Code, xFromBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xFromBin));

        LineNo := 10001;
        WhseJnlLineLast.Reset;
        WhseJnlLineLast.setrange("Journal Template Name", RecLocation.AppJournalTemplateName);
        WhseJnlLineLast.setrange("Journal Batch Name", RecLocation.AppJournalBatchName);
        WhseJnlLineLast.setrange("Location Code", RecBin."Location Code");
        if WhseJnlLineLast.findlast then
            LineNo := WhseJnlLineLast."Line No." + 10000;

        WhseJnlLine.init;
        WhseJnlLine."Journal Template Name" := RecLocation.AppJournalTemplateName;
        WhseJnlLine."Journal Batch Name" := RecLocation.AppJournalBatchName;
        WhseJnlLine.validate("Location Code", RecBin."Location Code");
        WhseJnlLine."Line No." := LineNo;
        WhseJnlLine.validate("Registering Date", workdate);
        WhseJnlLine.insert;
        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
        WhseJnlLine."Source Code" := 'DIARECLALM';
        WhseJnlLine.validate("Item No.", xItemNo);
        WhseJnlLine.validate("From Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("From Bin Code", xFromBin);

        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(Code, xToBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xToBin));


        WhseJnlLine.validate("To Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("To Bin Code", xToBin);
        WhseJnlLine.validate(Quantity, xQty);
        WhseJnlLine."Whse. Document No." := 'MOVE';
        //WhseJnlLine.Resource := Resource;

        WhseJnlLine.modify;


        if (xTrackNo <> '') then begin
            if WhseItemTrackingLineLast.findlast then;
            WhseItemTrackingLine.init;
            WhseItemTrackingLine."Entry No." := WhseItemTrackingLineLast."Entry No." + 1;
            WhseItemTrackingLine."Item No." := WhseJnlLine."Item No.";// xItemNo;
            WhseItemTrackingLine."Location Code" := RecBin."Location Code";
            WhseItemTrackingLine."Quantity (Base)" := xQty;
            WhseItemTrackingLine."Source Type" := 7311;
            WhseItemTrackingLine."Source ID" := RecLocation.AppJournalBatchName;
            WhseItemTrackingLine."Source Batch Name" := RecLocation.AppJournalTemplateName;
            WhseItemTrackingLine."Source Ref. No." := LineNo;
            WhseItemTrackingLine."Qty. per Unit of Measure" := 1;
            WhseItemTrackingLine."Qty. to Handle (Base)" := xQty;
            WhseItemTrackingLine."Qty. to Handle" := xQty; //"Qty. per Unit of Measure"

            sTipo := TipoSeguimientoProducto(xItemNo);
            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>

            if ((sTipo = 1) OR (sTipo = 3) OR (sTipo = 4) or (sTipo = 6)) THEN begin
                WhseItemTrackingLine."New Lot No." := xLotNo;
                WhseItemTrackingLine."Lot No." := xLotNo;
                WhseItemTrackingLine."Expiration Date" := Caducidad_Mov_Almacen(xItemNo, xLotNo, xSerialNo); // Caducidad_Ficha_Lote(xLotNo, xItemNo);
                WhseItemTrackingLine."New Expiration Date" := WhseItemTrackingLine."Expiration Date";

                //No permitir mover 2 lotes a una misma ubicación si esta parametrizada la opción
                RecWarehouseSetup.get();
                if (RecWarehouseSetup."Lote unico por ubicacion") then begin
                    clear(QueryLotInventory);
                    QueryLotInventory.SetRange(QueryLotInventory.Location_Code, xLocation);
                    QueryLotInventory.SetRange(QueryLotInventory.Bin_Code, xToBin);
                    QueryLotInventory.SetFilter(QueryLotInventory.Lot_No, '<>%1', xLotNo);
                    QueryLotInventory.Open();
                    IF QueryLotInventory.READ then ERROR(lblErrorLoteUnicoUbicacion);
                end;
            end;

            if ((sTipo = 2) OR (sTipo = 3) OR (sTipo = 5) or (sTipo = 6)) THEN begin
                WhseItemTrackingLine."Serial No." := xSerialNo;
                WhseItemTrackingLine."New Serial No." := xSerialNo;
            end;

            if ((sTipo = 4) OR (sTipo = 5) OR (sTipo = 6)) THEN begin
                WhseItemTrackingLine."Package No." := xPackageNo;
                WhseItemTrackingLine."New Package No." := newPackageNo;
            end;

            WhseItemTrackingLine.insert;

        end;

        //Commit();

        WhseJnlLine.reset;
        WhseJnlLine.SETRANGE("Whse. Document No.", 'MOVE');
        WhseJnlLine.SETRANGE("To Bin Code", '=%1', xToBin);
        IF WhseJnlLine.FindSet() then begin
            //Registrar
            CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch", WhseJnlLine);

            /*IF NOT CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch", WhseJnlLine) THEN begin
                txtError := GetLastErrorText();
                ERROR(txtError);
            end;*/
        end ELSE
            Error(lblErrorMover);

    end;

    procedure AppCreateReclassWarehouse(xLocation: Text; xFromBin: code[20]; xToBin: code[20]; xQty: decimal; xTrackNo: code[20]; xResourceNo: code[20]; xItemNo: code[20]; xLotNo: Text; xSerialNo: Text; xPackageNo: Text; newPackageNo: Text);
    var
        RecLocation: Record Location;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlLine: record "Item Journal Line";
        ItemJnlLineLast: record "Item Journal Line";
        RecBin: Record Bin;
        RecItem: Record Item;

        ReservationEntry: Record "Reservation Entry";
        ReservationEntryLast: Record "Reservation Entry";

        QueryLotInventory: Query "Lot Numbers by Bin";
        RecWarehouseSetup: Record "Warehouse Setup";

        //WhseItemTrackingLine: record "Whse. Item Tracking Line";
        //WhseItemTrackingLineLast: record "Whse. Item Tracking Line";
        LineNo: Integer;
        LineNoReserv: Integer;

        pg: page "Item Reclass. Journal";

        sTipo: Integer;

        ItemJnlRegisterLine: Codeunit "Item Jnl.-Post Line";
        //WhseJnlRegisterLine: codeunit "Whse. Jnl.-Register Line";
        txtError: Text;
        lblErrorReclasif: Label 'Not exist Reclassification Template', comment = 'ESP="No existe Libro diario Reclasificación"';

        DimensionSetID: Integer;

        TEX: Record "Tracking Specification";
    begin

        Clear(RecLocation);
        RecLocation.Get(xLocation);

        if (RecLocation.AppJournalTemplateName) = '' then Error(lblErrorReclasif);
        if (RecLocation.AppJournalBatchName) = '' then Error(lblErrorReclasif);

        /*ItemJnlTemplate.reset;
        ItemJnlTemplate.setrange(Type, ItemJnlTemplate.Type::);
        if not ItemJnlTemplate.findset then
            error(lblErrorReclasif);*/

        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", RecLocation.AppJournalTemplateName);
        ItemJnlLine.SETRANGE("Journal Batch Name", RecLocation.AppJournalBatchName);
        IF ItemJnlLine.findset then
            repeat
                ItemJnlLine.delete;
            until ItemJnlLine.Next = 0;

        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(Code, xFromBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xFromBin));

        LineNo := 10001;
        ItemJnlLineLast.Reset;
        ItemJnlLineLast.setrange("Journal Template Name", RecLocation.AppJournalTemplateName);
        ItemJnlLineLast.setrange("Journal Batch Name", RecLocation.AppJournalBatchName);
        ItemJnlLineLast.setrange("Location Code", RecBin."Location Code");
        if ItemJnlLineLast.findlast then
            LineNo := ItemJnlLineLast."Line No." + 10000;

        ItemJnlLine.init;

        ItemJnlLine.Validate("Journal Template Name", RecLocation.AppJournalTemplateName);
        ItemJnlLine.Validate("Journal Batch Name", RecLocation.AppJournalBatchName);

        ItemJnlLine.Validate("Item No.", xItemNo);

        Clear(RecItem);
        RecItem.Get(xItemNo);

        ItemJnlLine.Validate("Unit of Measure Code", RecItem."Base Unit of Measure");

        //Obtener Set de Dimensiones para el producto
        DimensionSetID := Obtener_Dimension_Set_Id(xItemNo);

        ItemJnlLine.Validate("Dimension Set ID", DimensionSetID);
        ItemJnlLine.Validate("New Dimension Set ID", DimensionSetID);


        //ItemJnlLine.Validate("Dimension Set ID", 12);
        //ItemJnlLine.Validate("New Dimension Set ID", 12);

        ItemJnlLine.validate("Location Code", RecBin."Location Code");
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine.validate("New Location Code", RecBin."Location Code");
        ItemJnlLine."Line No." := LineNo;
        ItemJnlLine.validate(ItemJnlLine."Posting Date", workdate);
        ItemJnlLine.insert;

        ItemJnlLine."Source Code" := 'RECLAS.JNL';
        ItemJnlLine."Document No." := 'MOVE';

        ItemJnlLine.validate("Bin Code", xFromBin);

        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(Code, xToBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xToBin));

        ItemJnlLine.validate(Quantity, xQty);
        ItemJnlLine."New Bin Code" := xToBin;

        //WhseJnlLine.Resource := Resource;

        ItemJnlLine.modify;


        if (xTrackNo <> '') then begin
            if ReservationEntryLast.findlast then
                LineNoReserv := ReservationEntryLast."Entry No." + 1
            else
                LineNoReserv := 1;


            ReservationEntry.init;
            ReservationEntry."Entry No." := LineNoReserv;
            ReservationEntry."Item No." := ItemJnlLine."Item No.";// xItemNo;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            ReservationEntry."Location Code" := RecBin."Location Code";
            ReservationEntry."Quantity (Base)" := -xQty;
            ReservationEntry."Source Type" := 83;
            ReservationEntry."Source Subtype" := 4;
            ReservationEntry."Source ID" := RecLocation.AppJournalTemplateName;
            ReservationEntry."Source Batch Name" := RecLocation.AppJournalBatchName;
            ReservationEntry."Source Ref. No." := LineNo;
            ReservationEntry."Qty. per Unit of Measure" := 1;
            ReservationEntry.Validate("Qty. to Handle (Base)", -xQty);
            ReservationEntry.Validate(Quantity, -xQty);
            ReservationEntry.Validate("Qty. to Invoice (Base)", -xQty);


            sTipo := TipoSeguimientoProducto(xItemNo);
            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>

            if ((sTipo = 1) OR (sTipo = 3) OR (sTipo = 4) or (sTipo = 6)) THEN begin
                ReservationEntry.Validate("Lot No.", xLotNo);
                ReservationEntry.Validate("New Lot No.", xLotNo);
                //ReservationEntry."Expiration Date" := Caducidad_Ficha_Lote(xLotNo, xItemNo);                

                //No permitir mover 2 lotes a una misma ubicación si esta parametrizada la opción
                RecWarehouseSetup.get();
                if (RecWarehouseSetup."Lote unico por ubicacion") then begin
                    clear(QueryLotInventory);
                    QueryLotInventory.SetRange(QueryLotInventory.Location_Code, xLocation);
                    QueryLotInventory.SetRange(QueryLotInventory.Bin_Code, xToBin);
                    QueryLotInventory.SetFilter(QueryLotInventory.Lot_No, '<>%1', xLotNo);
                    QueryLotInventory.Open();
                    IF QueryLotInventory.READ then ERROR(lblErrorLoteUnicoUbicacion);
                end;

            end;

            if ((sTipo = 2) OR (sTipo = 3) OR (sTipo = 5) or (sTipo = 6)) THEN begin



                ReservationEntry."Serial No." := xSerialNo;
                ReservationEntry."New Serial No." := xSerialNo;
            end;

            if ((sTipo = 4) OR (sTipo = 5) OR (sTipo = 6)) THEN begin
                ReservationEntry."Package No." := xPackageNo;
                ReservationEntry."New Package No." := newPackageNo;
            end;

            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
            case sTipo of
                1:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
                2:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Serial No.";
                3:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot and Serial No.";
                4:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot and Package No.";
                5:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Serial and Package No.";
                6:
                    ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot and Serial and Package No.";
            end;


            ReservationEntry."Expiration Date" := Caducidad_Mov_Almacen(xItemNo, xLotNo, xSerialNo);
            ReservationEntry."New Expiration Date" := ReservationEntry."Expiration Date";

            ReservationEntry.insert;

        end;

        //Commit();

        ItemJnlLine.reset;
        ItemJnlLine.SETRANGE("Document No.", 'MOVE');
        ItemJnlLine.SETRANGE("New Bin Code", '=%1', xToBin);
        IF ItemJnlLine.FindSet() then begin
            //Registrar
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJnlLine);
        end ELSE
            Error(lblErrorMover);

    end;


    local procedure Obtener_Dimension_Set_Id(xItemNo: Code[20]): Integer
    var
        Item: Record Item;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimensionSetID: Integer;
        DefaultDimension: Record "Default Dimension";
        DimSetEntry: Record "Dimension Set Entry";
    begin

        // Obtener dimensiones del artículo
        DefaultDimension.SetRange("Table ID", DATABASE::Item);
        DefaultDimension.SetRange("No.", xItemNo);
        if DefaultDimension.FindSet() then begin
            repeat
                Clear(DimSetEntry);
                DimSetEntry.SetRange("Dimension Code", DefaultDimension."Dimension Code");
                DimSetEntry.SetRange("Dimension Value Code", DefaultDimension."Dimension Value Code");
                if DimSetEntry.FindFirst() then begin

                    TempDimSetEntry.Init();

                    TempDimSetEntry."Dimension Set ID" := 1;
                    TempDimSetEntry."Dimension Code" := DefaultDimension."Dimension Code";
                    TempDimSetEntry."Dimension Value Code" := DefaultDimension."Dimension Value Code";
                    TempDimSetEntry."Dimension Value ID" := DimSetEntry."Dimension Value ID";
                    TempDimSetEntry."Dimension Name" := DimSetEntry."Dimension Name";
                    TempDimSetEntry."Dimension Value Name" := DimSetEntry."Dimension Value Name";

                    TempDimSetEntry.Insert();
                end;
            until DefaultDimension.Next() = 0;
        end;

        // Crear el nuevo Dimension Set ID o usar uno existente
        DimensionSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        exit(DimensionSetID);

    end;

    /*    local procedure Caducidad_Ficha_Lote(xLotNo: Code[50]; xItemNo: Code[50]): Date
        var
            RecLotNo: Record "Lot No. Information";
        begin
            Clear(RecLotNo);
            RecLotNo.SetRange("Item No.", xItemNo);
            RecLotNo.SetRange("Lot No.", xLotNo);
            if NOT RecLotNo.FindFirst() THEN ERROR(lblErrorTrackNo);

            IF (RecLotNo."Fecha Caducidad") <> 0D THEN begin
                exit(RecLotNo."Fecha Caducidad")
            end ELSE begin
                exit(0D);
            end;
        end;
    */
    local procedure Caducidad_Mov_Almacen(xItemNo: Code[20]; xLotNo: Code[20]; xSerialNo: Code[20]): Date
    var
        RecWarehouseEntry: Record "Warehouse Entry";
    begin

        if ((xLotNo = '') and (xSerialNo = ''))
            then
            exit(0D);

        Clear(RecWarehouseEntry);
        RecWarehouseEntry.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') then
            RecWarehouseEntry.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') then
            RecWarehouseEntry.SetRange("Serial No.", xSerialNo);
        RecWarehouseEntry.SetFilter(Quantity, '>%1', 0);
        RecWarehouseEntry.SetFilter("Expiration Date", '<>0D');
        if RecWarehouseEntry.FindLast() then
            exit(RecWarehouseEntry."Expiration Date");

        exit(0D)

    end;

    #endregion

    #region PICKING


    procedure Lineas_Picking(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectPicking: JsonObject;
        VJsonArrayPicking: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionEnvio: Text;

    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        if RecWarehouseActivityHeader.findset then begin

            VJsonObjectPicking.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectPicking.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));

            //VACIAR CANTIDAD A MANIPULAR
            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", RecWarehouseActivityHeader."No.");
            //RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
            RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
            IF RecWarehouseActivityLine.FindSet() THEN
                repeat
                    RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
                    RecWarehouseActivityLine.Modify();
                UNTIL RecWarehouseActivityLine.Next() = 0;

            repeat

                clear(RecWarehouseActivityLine);
                RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLine.SetRange("Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
                RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);
                RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
                if RecWarehouseActivityLine.FindSet() then begin
                    clear(RecWarehouseActivityLineAux);
                    RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityHeader."No.");
                    RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                    RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                    RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                    RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Place);
                    if RecWarehouseActivityLineAux.FindFirst() then
                        lUbicacionEnvio := RecWarehouseActivityLineAux."Bin Code";

                    repeat

                        VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                        VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));
                        VJsonObjectLineas.Add('BinFrom', RecWarehouseActivityLine."Bin Code");
                        VJsonObjectLineas.Add('BinTo', lUbicacionEnvio);
                        VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                        VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));

                        VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));
                        VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                        clear(VJsonObjectLineas);
                    until RecWarehouseActivityLine.Next() = 0;

                end;

                VJsonObjectPicking.Add('Lines', VJsonArrayLineas.Clone());
                Clear(VJsonArrayLineas);

                VJsonArrayPicking.Add(VJsonObjectPicking.Clone());
                clear(VJsonObjectPicking);

            until RecWarehouseActivityHeader.Next() = 0

        end;

        VJsonArrayPicking.WriteTo(VJsonText);

        exit(VJsonText);

    end;



    #endregion

    #region ALMACENAMIENTO


    procedure Lineas_Almacenamiento(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectAlmto: JsonObject;
        VJsonArrayAlmto: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionRecepcion: Text;
    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange("Location Code", xLocation);
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::"Put-away");
        if RecWarehouseActivityHeader.findset then begin
            repeat

                VJsonObjectAlmto := Objeto_Almacenamiento(RecWarehouseActivityHeader."No.");

                VJsonArrayAlmto.Add(VJsonObjectAlmto.Clone());
                clear(VJsonObjectAlmto);

            until RecWarehouseActivityHeader.Next() = 0

        end;

        VJsonArrayAlmto.WriteTo(VJsonText);

        exit(VJsonText);

    end;

    local procedure Objeto_Almacenamiento(xNo: Code[20]): JsonObject
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectAlmto: JsonObject;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionRecepcion: Text;
    begin

        CLEAR(VJsonObjectAlmto);

        Clear(RecWarehouseActivityHeader);
        RecWarehouseActivityHeader.SetRange("No.", xNo);
        if RecWarehouseActivityHeader.FindFirst() then BEGIN

            //VACIAR CANTIDAD A MANIPULAR
            /*clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", xNo);
            RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
            IF RecWarehouseActivityLine.FindSet() THEN
                repeat
                    RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
                    RecWarehouseActivityLine.Modify();
                UNTIL RecWarehouseActivityLine.Next() = 0;*/

            VJsonObjectAlmto.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectAlmto.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));

            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
            //RecWarehouseActivityLine.SetRange("Source Document", RecWarehouseActivityLine."Source Document"::"Purchase Order");
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
            RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
            if RecWarehouseActivityLine.FindSet() then begin
                clear(RecWarehouseActivityLineAux);
                RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Take);
                if RecWarehouseActivityLineAux.FindFirst() then
                    lUbicacionRecepcion := RecWarehouseActivityLineAux."Bin Code";

                repeat
                    VJsonObjectLineas.Add('No', RecWarehouseActivityLine."No.");
                    VJsonObjectLineas.Add('SourceNo', RecWarehouseActivityLine."Source No.");
                    VJsonObjectLineas.Add('SourceLineNo', RecWarehouseActivityLine."Source Line No.");
                    VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                    VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));
                    VJsonObjectLineas.Add('BinFrom', lUbicacionRecepcion);
                    VJsonObjectLineas.Add('BinTo', RecWarehouseActivityLine."Bin Code");
                    VJsonObjectLineas.Add('LotNo', RecWarehouseActivityLine."Lot No.");
                    VJsonObjectLineas.Add('SerialNo', RecWarehouseActivityLine."Serial No.");
                    VJsonObjectLineas.Add('PackageNo', RecWarehouseActivityLine."Package No.");
                    VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                    VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));

                    VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));
                    VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                    clear(VJsonObjectLineas);
                until RecWarehouseActivityLine.Next() = 0;

            end ELSE begin
                VJsonObjectAlmto.Add('No', '');
            end;

            VJsonObjectAlmto.Add('Lines', VJsonArrayLineas.Clone());
            Clear(VJsonArrayLineas);

        END;

        exit(VJsonObjectAlmto);
    end;

    local procedure Registrar_Almacenamiento(xNo: Text; xLotNo: Text; xItemNo: Text; jBinTo: Text; xSerialNo: Text; xQuantity: decimal; xLineNoTake: Integer; xLineNoPlace: integer): Text
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";

        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        txtError: Text;
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);

        RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoPlace);
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Bin Code", jBinTo);
            if (RecWarehouseActivityLine."Lot No." = '') then RecWarehouseActivityLine."Lot No." := xLotNo;
            if (RecWarehouseActivityLine."Serial No." = '') then RecWarehouseActivityLine."Serial No." := xSerialNo;
            RecWarehouseActivityLine.Modify();
        end;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);

        RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
        RecWarehouseActivityLine.SetFilter("Line No.", '=%1|%2', xLineNoPlace, xLineNoPlace);

        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine)
        /*IF NOT cuWarehouseActivityRegister.run(RecWarehouseActivityLine) THEN begin
            txtError := GetLastErrorText();
            ERROR(txtError);
        end*/
        ELSE
            Error(lblErrorSinAlmacenamiento);

        VJsonObjectAlmacenamiento := Objeto_Almacenamiento(xNo);
        VJsonObjectAlmacenamiento.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    /// <summary>
    /// Registrar_Movimiento.
    /// </summary>
    /// <param name="xNo">Text.</param>
    /// <param name="xDocumentType">Enum "Warehouse Activity Document Type".</param>
    /// <param name="xDocumentNo">Text.</param>
    /// <param name="xDocumentLineNo">Integer.</param>
    /// <param name="xBinTo">Text.</param>
    /// <param name="xQuantity">decimal.</param>
    /// <param name="xItemNo">Text.</param>
    /// <param name="xLotNo">Text.</param>
    /// <param name="xSerialNo">Text.</param>
    local procedure Registrar_Movimiento(xNo: Text; xLineNoTake: Integer; xLineNoPlace: Integer; xDocumentType: Enum "Warehouse Activity Document Type"; xDocumentNo: Text;
                                                                                                                    xDocumentLineNo: Integer;
                                                                                                                    xBinFrom: Text;
                                                                                                                    xBinTo: Text;
                                                                                                                    xQuantity: decimal;
                                                                                                                    xItemNo: Text;
                                                                                                                    xLotNo: Text;
                                                                                                                    xSerialNo: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineReg: Record "Warehouse Activity Line";

        RecRecurso: Record Resource;

        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";

        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        txtError: Text;
        FechaCaducidad: Date;
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoPlace);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>=%1', xQuantity);

        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        if ((xDocumentType <> RecWarehouseActivityLine."Whse. Document Type"::Shipment)
            and (xDocumentType <> RecWarehouseActivityLine."Whse. Document Type"::Production))
        then begin
            if (xLotNo <> '') THEN
                RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
            if (xSerialNo <> '') THEN
                RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);
        end;

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

        if NOT RecWarehouseActivityLine.FindFirst() then Error(lblErrorSinMovimiento);

        FechaCaducidad := RecWarehouseActivityLine."Expiration Date";

        IF RecWarehouseActivityLine."Qty. Outstanding" <> xQuantity THEN BEGIN
            //Dividimos linea
            //RecWarehouseActivityLine.SplitLine(RecWarehouseActivityLine);

            //Place
            Cortar_Linea(xNo, xLineNoPlace, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo, xQuantity, xItemNo, xLotNo, xSerialNo, false);
            //Take
            Cortar_Linea(xNo, xLineNoTake, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo, xQuantity, xItemNo, xLotNo, xSerialNo, true);

            Clear(RecWarehouseActivityLine);
            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange("No.", xNo);
            RecWarehouseActivityLine.SetRange("Line No.", xLineNoPlace);
            RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
            RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>=%1', xQuantity);

            if (xDocumentNo <> '') then
                RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source No.", xDocumentNo);
            if (xDocumentLineNo <> 0) then
                RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Line No.", xDocumentLineNo);
            RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

            if ((xDocumentType <> RecWarehouseActivityLine."Whse. Document Type"::Shipment)
                and (xDocumentType <> RecWarehouseActivityLine."Whse. Document Type"::Production))
            then begin
                if (xLotNo <> '') THEN
                    RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
                if (xSerialNo <> '') THEN
                    RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);
            end;
            RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

            if NOT RecWarehouseActivityLine.FindFirst() then Error(lblErrorSinMovimiento);

        end;

        RecWarehouseActivityLine.Validate("Qty. to Handle", xQuantity);

        if ((RecWarehouseActivityLine."Whse. Document Type" = RecWarehouseActivityLine."Whse. Document Type"::Shipment)
            OR (RecWarehouseActivityLine."Whse. Document Type" = RecWarehouseActivityLine."Whse. Document Type"::Production))
         then begin
            if (xLotNo <> '') THEN
                RecWarehouseActivityLine.Validate("Lot No.", xLotNo);
            if (xSerialNo <> '') THEN
                RecWarehouseActivityLine.Validate("Serial No.", xSerialNo);

            //Cambiar el lote/serie también el take
            Cambiar_Track_Movimiento_Take(xNo, xLineNoTake, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo,
                                            xItemNo, xLotNo, xSerialNo, FechaCaducidad);
        end else begin
            RecWarehouseActivityLine.Validate("Bin Code", xBinTo);
        end;

        RecWarehouseActivityLine.Validate("Expiration Date", FechaCaducidad);
        RecWarehouseActivityLine.Modify();

        clear(RecWarehouseActivityLineReg);
        RecWarehouseActivityLineReg.SetRange("No.", xNo);
        RecWarehouseActivityLineReg.SetRange("Whse. Document Type", xDocumentType);
        //if (xDocumentNo <> '') then
        //    RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source No.", xDocumentNo);
        //if (xDocumentLineNo <> 0) then
        //    RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Line No.", xDocumentLineNo);
        RecWarehouseActivityLineReg.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLineReg.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLineReg.SetRange("Serial No.", xSerialNo);

        RecWarehouseActivityLineReg.SetRange("Source No.", RecWarehouseActivityLine."Source No.");
        RecWarehouseActivityLineReg.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
        //RecWarehouseActivityLineReg.SetFilter("Qty. Outstanding", '>=%1', xQuantity);
        RecWarehouseActivityLineReg.SetFilter("Line No.", '%1|%2', xLineNoPlace, xLineNoTake);

        if RecWarehouseActivityLineReg.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLineReg)
        ELSE
            Error(lblErrorSinMovimiento);
    end;


    local procedure Cambiar_Track_Movimiento_Take(xNo: Text; xLineNoTake: Integer; xDocumentType: Enum "Warehouse Activity Document Type";
                                                                                                     xDocumentNo: Text;
                                                                                                      xDocumentLineNo: Integer;
                                                                                                      xBinFrom: Text;
                                                                                                      xBinTo: Text;
                                                                                                      xItemNo: Text;
                                                                                                      xLotNo: Text;
                                                                                                      xSerialNo: Text;
                                                                                                      xFechaCaducidad: Date)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoTake);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);

        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Bin Code", xBinFrom);
            if (xLotNo <> '') THEN
                RecWarehouseActivityLine.Validate("Lot No.", xLotNo);
            if (xSerialNo <> '') THEN
                RecWarehouseActivityLine.Validate("Serial No.", xSerialNo);

            RecWarehouseActivityLine.Validate("Expiration Date", xFechaCaducidad);

            RecWarehouseActivityLine.Modify();
        end ELSE
            Error(lblErrorSinMovimiento);

    end;


    local procedure Cortar_Linea(xNo: Text; xLineNo: Integer; xDocumentType: Enum "Warehouse Activity Document Type"; xDocumentNo: Text;
                                                                                     xDocumentLineNo: Integer;
                                                                                     xBinFrom: Text;
                                                                                     xBinTo: Text;
                                                                                     xQuantity: decimal;
                                                                                     xItemNo: Text;
                                                                                     xLotNo: Text;
                                                                                     xSerialNo: Text;
                                                                                     xEsTake: Boolean)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNo);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        if xEsTake then
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take)
        else
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Qty. to Handle", xQuantity);
            RecWarehouseActivityLine.SplitLine(RecWarehouseActivityLine);

            RecWarehouseActivityLine.Modify();
        end;

        RecWarehouseActivityLineAux.Reset();
        RecWarehouseActivityLineAux.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type");
        RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityLine."No.");
        RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLine."Action Type");
        RecWarehouseActivityLineAux.SetRange("Location Code", RecWarehouseActivityLine."Location Code");
        RecWarehouseActivityLineAux.setrange("Item No.", RecWarehouseActivityLine."Item No.");
        RecWarehouseActivityLineAux.setFILTER("Bin Code", '=%1', '');
        if RecWarehouseActivityLineAux.FindFirst() then begin
            RecWarehouseActivityLineAux.Validate("Bin Code", RecWarehouseActivityLine."Bin Code");
            //WarehouseALPutAux.Resource := pRecurso; //PX20221014
            RecWarehouseActivityLineAux.Modify();
        end;


    end;


    #endregion

    #region ENVIOS

    local procedure Objeto_Envio(xNo: code[20]): JsonObject
    var
        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        RecSalesHeader: Record "Sales Header";
        RecItemReference: Record "Item Reference";
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecSalesLine: Record "Sales Line";
        RecComentarios: Record "Warehouse Comment Line";
        RecItem: Record Item;
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectShipments: JsonObject;
        VJsonArrayShipments: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        CR: Char;
    begin

        CR := 13;

        RecWarehouseSetup.Get();

        clear(RecWhsShipmentHeader);
        RecWhsShipmentHeader.SetRange("No.", xNo);
        if RecWhsShipmentHeader.FindFirst() then;

        //Actualizar_Cantidad_Enviar(RecWhsShipmentHeader."No.");

        Clear(VJsonObjectShipments);

        VJsonObjectShipments.Add('No', RecWhsShipmentHeader."No.");
        VJsonObjectShipments.Add('Date', FormatoFecha(RecWhsShipmentHeader."Posting Date"));
        VJsonObjectShipments.Add('CustomerName', '');
        VJsonObjectShipments.Add('Status', FORMAT(RecWhsShipmentHeader."Document Status"));
        if (RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Completely Picked") THEN
            VJsonObjectShipments.Add('CompletelyPicked', 'True')
        ELSE
            VJsonObjectShipments.Add('CompletelyPicked', 'False');

        if ((RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Partially Picked")
        or (RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Partially Shipped")) THEN
            VJsonObjectShipments.Add('PartiallyPicked', 'True')
        ELSE
            VJsonObjectShipments.Add('PartiallyPicked', 'False');


        //Comentarios

        Comentarios := '';
        Clear(RecComentarios);
        RecComentarios.SetRange("Table Name", RecComentarios."Table Name"::"Whse. Shipment");
        RecComentarios.SetRange("No.", RecWhsShipmentHeader."No.");
        //RecComentarios.SetRange(RecComentarios."Tipo Comentario", RecComentarios."Tipo Comentario"::APP);
        if RecComentarios.FindSet(false) then begin
            VJsonObjectShipments.Add('TieneComentarios', 'true');
            repeat
                Comentarios += RecComentarios.Comment + '-*-';
            until RecComentarios.Next() = 0;
        END ELSE
            VJsonObjectShipments.Add('TieneComentarios', 'false');

        VJsonObjectShipments.Add('Comentarios', Comentarios);

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", RecWhsShipmentHeader."No.");

        if RecWhsShipmentLine.FindSet() then begin

            //Buscar el nombre del proveedor                    
            if RecWhsShipmentLine."Source Document" = RecWhsShipmentLine."Source Document"::"Sales Order" then begin
                Clear(RecSalesHeader);
                RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::Order);
                RecSalesHeader.SetRange("No.", RecWhsShipmentLine."Source No.");
                if RecSalesHeader.FindFirst() then
                    VJsonObjectShipments.Replace('CustomerName', RecSalesHeader."Sell-to Customer Name");

            end;

            repeat
                VJsonObjectLines.Add('No', RecWhsShipmentHeader."No.");
                VJsonObjectLines.Add('LineNo', FormatoNumero(RecWhsShipmentLine."Line No."));

                VJsonObjectLines.Add('SourceNo', RecWhsShipmentLine."Source No.");
                VJsonObjectLines.Add('SourceLineNo', RecWhsShipmentLine."Source Line No.");

                VJsonObjectLines.Add('Reference', RecWhsShipmentLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsShipmentLine.Description);

                VJsonObjectLines.Add('Zone', RecWhsShipmentLine."Zone Code");
                VJsonObjectLines.Add('Bin', RecWhsShipmentLine."Bin Code");

                VJsonObjectLines.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWhsShipmentLine."Item No.")));
                VJsonObjectLines.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));

                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsShipmentLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsShipmentLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToShip', RecWhsShipmentLine."Qty. to Ship (Base)");// ."Qty. to Receive");

                if (RecWhsShipmentLine."Qty. to Ship (Base)" < RecWhsShipmentLine."Qty. Outstanding (Base)") then begin
                    VJsonObjectLines.Add('Complete', false);
                    if (RecWhsShipmentLine."Qty. to Ship (Base)" > 0) then
                        VJsonObjectLines.Add('Partial', true)
                    else
                        VJsonObjectLines.Add('Partial', false);

                end else begin
                    VJsonObjectLines.Add('Complete', true);
                    VJsonObjectLines.Add('Partial', false);
                end;


                //Se busca si tiene lote predefinido
                /*clear(RecPurchaseLine);
                RecPurchaseLine.SetRange("Document No.", RecWhsReceiptLine."Source No.");
                RecPurchaseLine.SetRange("Line No.", RecWhsReceiptLine."Source Line No.");
                if RecPurchaseLine.FindFirst() then
                    VJsonObjectLines.Add('Preasignado', RecPurchaseLine."Lote preasignado")
                else
                    VJsonObjectLines.Add('Preasignado', 'BAD' + RecWhsReceiptLine."Source No." + '--' + RecPurchaseLine."Lote preasignado");
                */

                Clear(VJsonArrayReservas);
                VJsonArrayReservas := Reservas_Envios(RecWhsShipmentLine);
                VJsonObjectLines.Add('Reservations', VJsonArrayReservas);

                VJsonArrayLines.Add(VJsonObjectLines.Clone());
                clear(VJsonObjectLines);

            until RecWhsShipmentLine.Next() = 0;

            VJsonObjectShipments.Add('Lines', VJsonArrayLines);

            Clear(VJsonArrayLines);
            Clear(VJsonObjectLines);

        end;

        exit(VJsonObjectShipments);

    end;

    local procedure Actualizar_Cantidad_Enviar(xEnvio: Text)
    var
        RecWhseShipmentLine: Record "Warehouse Shipment Line";
        RecReservationEntry: Record "Reservation Entry";
        CantidadReservada: Decimal;
    begin

        clear(RecWhseShipmentLine);
        RecWhseShipmentLine.SETRANGE("No.", xEnvio);
        IF RecWhseShipmentLine.FINDSET THEN begin
            RecWhseShipmentLine.Validate("Qty. to Ship", 0);
            RecWhseShipmentLine.MODIFY();
            REPEAT
                CantidadReservada := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
                RecReservationEntry.SETRANGE("Source ID", RecWhseShipmentLine."Source No.");
                RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseShipmentLine."Source Line No.");
                RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
                IF RecReservationEntry.FINDSET THEN
                    REPEAT
                        CantidadReservada := CantidadReservada + (-RecReservationEntry.Quantity);
                    UNTIL RecReservationEntry.NEXT = 0;

                RecWhseShipmentLine.Validate("Qty. to Ship", CantidadReservada / RecWhseShipmentLine."Qty. per Unit of Measure");// ("Qty. to Receive", CantidadReservada);

                RecWhseShipmentLine.MODIFY();
            UNTIL RecWhseShipmentLine.NEXT = 0;
        end;
    end;

    local procedure Reservas_Envios(RecWhseShipmentLine: Record "Warehouse Shipment Line"): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
        RecReservationEntry.SETRANGE("Source ID", RecWhseShipmentLine."Source No.");
        RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseShipmentLine."Source Line No.");
        RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT
                VJsonObjectReservas.Add('No', RecWhseShipmentLine."No.");
                VJsonObjectReservas.Add('LineNo', FormatoNumero(RecWhseShipmentLine."Line No."));
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('PackageNo', RecReservationEntry."Package No.");

                VJsonObjectReservas.Add('Quantity', FormatoNumero(-RecReservationEntry."Quantity (Base)"));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;


    /*
        local procedure Sugerencias_Envios(RecWhseShipmentLine: Record "Warehouse Shipment Line"): JsonArray
        var
            QueryLotInventory: Query "Lot Numbers by Bin Exp";
            RecWarehouseSetup: Record "Warehouse Setup";
            RecReservationEntry: Record "Reservation Entry";
            VJsonObjectFEFO: JsonObject;
            VJsonArrayFEFO: JsonArray;

            Contador: Integer;

            CantidadEnReservas: Integer;
        begin

            RecWarehouseSetup.Get();
            if RecWarehouseSetup."Work Location" = '' THEN ERROR('No se ha definido el almacén de trabajo en la configuración');
            if RecWarehouseSetup."Work Bin" = '' THEN ERROR('No se ha definido la ubicación de trabajo en la configuración');

            VJsonObjectFEFO.Add('ItemNo', '');
            VJsonObjectFEFO.Add('LotNo', '');
            VJsonObjectFEFO.Add('Quantity', '');
            VJsonObjectFEFO.Add('ExpirationDate', '');

            Clear(QueryLotInventory);
            QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', RecWhseShipmentLine."Item No.");
            QueryLotInventory.SetRange(QueryLotInventory.Location_Code, RecWarehouseSetup."Work Location");
            QueryLotInventory.SetRange(QueryLotInventory.Bin_Code, RecWarehouseSetup."Work Bin");
            QueryLotInventory.Open();
            Contador := 0;
            WHILE ((QueryLotInventory.READ) AND (Contador <= 5)) DO BEGIN

                //Buscar si ya está en reservas
                CantidadEnReservas := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
                RecReservationEntry.SetRange("Source Type", 37);
                RecReservationEntry.SetRange("Source Subtype", 1);
                RecReservationEntry.SetRange("Lot No.", QueryLotInventory.Lot_No);
                IF RecReservationEntry.FindSet() then
                    repeat
                        CantidadEnReservas += (-RecReservationEntry.Quantity);
                    until RecReservationEntry.Next() = 0;

                if (QueryLotInventory.Sum_Qty_Base > CantidadEnReservas) then begin

                    VJsonObjectFEFO.Replace('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectFEFO.Replace('LotNo', QueryLotInventory.Lot_No);
                    VJsonObjectFEFO.Replace('Quantity', QuitarPunto(Format(QueryLotInventory.Sum_Qty_Base - CantidadEnReservas)));
                    VJsonObjectFEFO.Replace('ExpirationDate', Format(QueryLotInventory.Expiration_Date, 10, '<day,2>/<month,2>/<year4>'));

                    VJsonArrayFEFO.Add(VJsonObjectFEFO.Clone());

                    Contador += 1;

                end;
            end;

            exit(VJsonArrayFEFO);
        end;
    */

    procedure Asignar(xCantidad: Integer; xItemNo: Code[50]; xLocation: Code[50]; xLotNo: Code[50]; xSerialNo: Code[50]; xPackageNo: Code[50]; xOrder: Code[50]; xLine: Integer): Text
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackageNo: Record "Package No. Information";
        RecReservationEntry: Record "Reservation Entry";
        RecWarehouseSetup: Record "Warehouse Setup";
        JsonText: Text;
        NumLinea: Integer;

    begin
        RecWarehouseSetup.Get();
        //if RecWarehouseSetup."Work Location" = '' THEN ERROR('No se ha definido el almacén de trabajo en la configuración');
        //if RecWarehouseSetup."Work Bin" = '' THEN ERROR('No se ha definido la ubicación de trabajo en la configuración');


        Clear(RecReservationEntry);
        IF RecReservationEntry.FindLast() THEN
            NumLinea := RecReservationEntry."Entry No." + 1
        else
            NumLinea := 1;


        if (xCantidad > 0) then begin

            //Buscar si existe ese lote
            Clear(RecReservationEntry);
            RecReservationEntry.SetRange("Source Type", 37);
            RecReservationEntry.SetRange("Source Subtype", 1);
            RecReservationEntry.SetRange("Item No.", xItemNo);
            RecReservationEntry.SetRange(RecReservationEntry."Location Code", xLocation);
            RecReservationEntry.SetRange("Reservation Status", RecReservationEntry."Reservation Status"::Surplus);
            RecReservationEntry.SetRange("Source ID", xOrder); //1007
            RecReservationEntry.SetRange("Source Ref. No.", xLine); //10000
            IF (xLotNo <> '') then begin
                if not Existe_Lote(xLotNo, xItemNo) then Error(lblErrorLote);

                RecReservationEntry.SetRange("Lot No.", xLotNo);
            end;
            IF (xSerialNo <> '') then begin
                if not Existe_Serie(xSerialNo) then Error(lblErrorSerie);
                if Existe_Serie_En_Envio(xSerialNo) then Error(lblErrorSerialDuplicadoEnvio);

                RecReservationEntry.SetRange("Serial No.", xSerialNo);
            end;
            IF (xPackageNo <> '') then begin
                if not Existe_Paquete(xPackageNo) then Error(lblErrorPaquete);

                RecReservationEntry.SetRange("Package No.", xPackageNo);
            end;
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", RecReservationEntry."Quantity (Base)" - xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, RecReservationEntry.Quantity - xCantidad);
                RecReservationEntry.MODIFY();
            end else begin


                RecReservationEntry.Init();
                RecReservationEntry."Entry No." := NumLinea;
                RecReservationEntry.Validate("Source Type", 37);
                RecReservationEntry.Validate("Source Subtype", 1);
                RecReservationEntry.Validate("Item No.", xItemNo);
                RecReservationEntry.Validate(RecReservationEntry."Location Code", xLocation);
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", -xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, -xCantidad);
                RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
                RecReservationEntry.Validate("Source ID", xOrder); //1007
                RecReservationEntry.Validate("Source Ref. No.", xLine); //10000

                case TipoSeguimientoProducto(xItemNo) of
                    0://Sin Seguimiento
                        begin
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::None);
                        end;
                    1://Lote
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot No.");
                        end;
                    2://Serie
                        begin

                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Serial No.");
                        end;
                    3://Lote y Serie
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Serial No.");
                        end;
                    4://Lote y Paquete
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Package No.");
                        end;
                    5://Serie y Paquete
                        begin
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Serial and Package No.");
                        end;
                    6://Lote, Serie y Paquete
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Serial and Package No.");
                        end;
                end;

                RecReservationEntry.Insert();
            end;

        end;






    end;

    procedure Eliminar_De_Envio(xCantidad: Integer; xEntryNo: Integer): Text
    var
        RecLotNo: Record "Lot No. Information";
        RecReservationEntry: Record "Reservation Entry";
        RecWarehouseSetup: Record "Warehouse Setup";
        JsonText: Text;
        NumLinea: Integer;

    begin

        if (xCantidad > 0) then begin

            //Buscar si existe ese lote
            Clear(RecReservationEntry);
            RecReservationEntry.SetRange("Source Type", 37);
            RecReservationEntry.SetRange("Source Subtype", 1);
            RecReservationEntry.SetRange("Entry No.", xEntryNo);
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", RecReservationEntry."Quantity (Base)" + xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, RecReservationEntry.Quantity + xCantidad);
                RecReservationEntry.MODIFY();
                if RecReservationEntry."Quantity (Base)" = 0 then RecReservationEntry.Delete();
            end;
        end;

    end;

    local procedure Existe_Serie_En_Envio(xSerialNo: Text): Boolean
    var
        RecReservationEntry: Record "Reservation Entry";
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetRange("Source Type", 37);
        RecReservationEntry.SetRange("Source Subtype", 1);
        RecReservationEntry.SetRange("Serial No.", xSerialNo);
        if RecReservationEntry.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    procedure Registrar_Envio(xEnvio: Text; xLinea: Integer) Estado: Text
    var
        WhseShipmentHeader: record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        PostedWhseShipLine: record "Posted Whse. Shipment Line";
        WhsePostShipmentMgt: Codeunit "Whse.-Post Shipment";
        SalesShipmentLine: Record "Sales Shipment Line";
        txtError: Text;
    begin

        WhseShipmentHeader.Reset;
        WhseShipmentHeader.SetRange("No.", xEnvio);
        IF NOT WhseShipmentHeader.Findfirst then error(lblErrorEnvio);

        WhseShipmentHeader."Posting Date" := WORKDATE;
        WhseShipmentHeader.Modify;

        //Actualizar_Cantidad_Enviar(xEnvio);
        WhseShipmentLine.RESET;
        WhseShipmentLine.SETRANGE("No.", xEnvio);
        if (xLinea > 0) then
            WhseShipmentLine.SETRANGE("Line No.", xLinea);


        IF WhseShipmentLine.FindSet() THEN BEGIN
            WhsePostShipmentMgt.RUN(WhseShipmentLine);

            /*IF NOT WhsePostShipmentMgt.RUN(WhseShipmentLine) THEN begin
                txtError := GetLastErrorText();
                ERROR(txtError);
            end;*/
        END;

        /*IF Estado = 'True' then begin
            PostedWhseShipLine.Reset;
            PostedWhseShipLine.SetCurrentKey("Whse. Shipment No.", "Whse Shipment Line No.");
            PostedWhseShipLine.SetRange("Whse. Shipment No.", xEnvio);
            PostedWhseShipLine.SetRange("Source Document", PostedWhseShipLine."Source Document"::"Sales Order");
            PostedWhseShipLine.Setfilter("Source No.", '<>%1');
            IF PostedWhseShipLine.Findfirst then begin
                SalesShipmentLine.Reset();
                SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                SalesShipmentLine.SetRange("Order No.", PostedWhseShipLine."Source No.");
                SalesShipmentLine.SetRange("Order Line No.", PostedWhseShipLine."Source Line No.");
                IF SalesShipmentLine.Findfirst then begin
                    PrinterMgt.Impresion_Albaran(SalesShipmentLine."Document No.");
                end;
            end;
        end;*/
    end;

    procedure Crear_Picking(xNo: Code[50])
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseShptLineAux: Record "Warehouse Shipment Line";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        WhsePickLineAux: Record "Warehouse Activity Line";
    begin



        Clear(WhseShptLineAux);
        WhseShptLineAux.SetRange("No.", xNo);
        IF Not WhseShptLineAux.FindSet() then ERROR(lblErrorNadaQueRegistrar);


        // Verificar si ya existe un picking asociado al envío (xNo)
        Clear(WhsePickLineAux);
        WhsePickLineAux.SETRANGE("Whse. Document No.", xNo);
        IF NOT WhsePickLineAux.FINDSET() THEN BEGIN

            WhseShptLine.Copy(WhseShptLineAux);

            WhseShptHeader.Get(xNo);
            if WhseShptHeader.Status = WhseShptHeader.Status::Open then
                ReleaseWhseShipment.Release(WhseShptHeader);

            WhseShptLineAux.CreatePickDoc(WhseShptLine, WhseShptHeader);

        END;

    end;


    #endregion

    #region INVENTARIO


    procedure Inventario_Trazabilidad(xLocation: Text; xTrackNo: Text; xItemNo: Text): Text
    var

        lTipo: Code[1];

        RecWarehouseSetup: record "Warehouse Setup";
        QueryLotInventory: Query "Lot Numbers by Bin";
        RecItem: Record Item;

        VJsonObjectTrazabilidad: JsonObject;

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        Cantidad: Decimal;
        Iventario: Decimal;
        VJsonText: Text;

        Encontrado: Boolean;

        Primero: Boolean;
        vPaquete: Text;
        vSerie: Text;

        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;

        RecLocation: Record Location;
    begin

        RecWarehouseSetup.Get();

        if (xItemNo <> '') then begin

            clear(RecItem);
            RecItem.SetRange("No.", xItemNo);
            if not RecItem.FindFirst() then begin
                xItemNo := Buscar_Item_De_Referencia_Cruzada(xItemNo);
            end;

        end;

        lTipo := 'N';
        if (xTrackNo <> '') then
            lTipo := Tipo_Trazabilidad(xTrackNo)
        else
            if (xItemNo <> '') then lTipo := Tipo_Trazabilidad(xItemNo);

        if (lTipo = 'N') THEN begin
            //Buscar si es una referencia cruzada 
            xTrackNo := Buscar_Item_De_Referencia_Cruzada(xTrackNo);
            if (xTrackNo = '') then
                ERROR(lblErrorTrackNo + ' (' + xTrackNo + ')')
            else
                lTipo := 'I';
        end;

        VJsonObjectTrazabilidad.Add('TrackNo', xTrackNo);

        Clear(RecLocation);
        RecLocation.Get(xLocation);
        RecLocation.CalcFields("Tiene Ubicaciones");
        if RecLocation."Almacen Avanzado" or RecLocation."Tiene Ubicaciones" then begin

            Clear(QueryLotInventory);
            case lTipo of
                'L':
                    begin
                        QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xTrackNo);
                    end;
                'S':
                    begin
                        QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xTrackNo);
                    end;
                'P':
                    begin
                        QueryLotInventory.SetRange(QueryLotInventory.Package_No, xTrackNo);
                    end;
                'I':
                    begin
                        QueryLotInventory.SetRange(QueryLotInventory.Item_No, xTrackNo);
                    end;
                else
            end;

            if (xItemNo <> '') then
                QueryLotInventory.SetRange(QueryLotInventory.Item_No, xItemNo);

            //QueryLotInventory.Open();
            //Inventario por ubicación

            QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, xLocation);

            Primero := true;
            Cantidad := 0;
            QueryLotInventory.Open();
            WHILE QueryLotInventory.READ DO BEGIN
                if (Primero) then begin
                    VJsonObjectTrazabilidad.Add('Tipo', lTipo);
                    VJsonObjectTrazabilidad.Add('TipoDesc', Desc_Tipo(lTipo));

                    IF ((lTipo = 'P') OR (lTipo = 'L')) THEN begin

                        VJsonObjectTrazabilidad.Add('ItemNo', '');
                        VJsonObjectTrazabilidad.Add('Description', '');
                    end;
                    IF ((lTipo = 'S') OR (lTipo = 'I')) THEN begin
                        VJsonObjectTrazabilidad.Add('ItemNo', QueryLotInventory.Item_No);
                        VJsonObjectTrazabilidad.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                    end;
                    Primero := false;
                end;

                VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
                VJsonObjectInventario.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));

                iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);
                VJsonObjectInventario.Add('TipoSeguimiento', Format(iTipoTrack));

                /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
                case iTipoTrack of
                    0:
                        begin
                            VJsonObjectInventario.Add('TrackNo', '');
                            VJsonObjectInventario.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                            VJsonObjectInventario.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                            VJsonObjectInventario.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
                VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);
                VJsonObjectInventario.Add('PackageNo', QueryLotInventory.Package_No);

                if (QueryLotInventory.Package_No <> '') then begin
                    if (RecWarehouseSetup."Codigo Sin Paquete" <> '') then begin
                        if (RecWarehouseSetup."Codigo Sin Paquete" <> QueryLotInventory.Package_No) then begin
                            VJsonObjectInventario.Add('InPackage', FormatoBoolean(True));
                        end else begin
                            VJsonObjectInventario.Add('InPackage', FormatoBoolean(False));
                        end;
                    end ELSE begin
                        VJsonObjectInventario.Add('InPackage', FormatoBoolean(True));
                    end;
                END ELSE begin
                    VJsonObjectInventario.Add('InPackage', FormatoBoolean(False));
                end;




                VJsonObjectInventario.Add('Zone', QueryLotInventory.Zone_Code);
                VJsonObjectInventario.Add('Bin', QueryLotInventory.Bin_Code);
                VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty_Base));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            END;

            VJsonObjectTrazabilidad.Add('Bins', VJsonArrayInventario.Clone());

        end else begin

        end;

        QueryLotInventory.Close();

        VJsonObjectTrazabilidad.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    local procedure Desc_Tipo(xTipo: Text): Text
    var

    begin
        case xTipo of
            'I':
                exit(lblReferencia);
            'L':
                exit(lblLote);
            'S':
                exit(lblSerie);
            'P':
                exit(lblPaquete);
            else
                exit('');
        end;
    end;


    procedure Inventario_Recurso(xResourceNo: Text; xLocation: Text; xZone: Text; xBin: Text; xItemNo: Text): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        //RecWarehouseJournalLine: Record "Warehouse Journal Line";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecDiario: RecordRef;
        RecLocation: Record Location;
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;
    begin

        if (xResourceNo = '') then ERROR(lblErrorRecurso);

        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        if ((RecLocation.AppInvJournalTemplateName = '') or (RecLocation.AppInvJournalBatchName = '')) then
            ERROR(lblErrorDiarioInv);

        Clear(RecRecurso);
        RecRecurso.SetRange("No.", xResourceNo);
        if not RecRecurso.FindFirst() THEN ERROR(lblErrorRecurso);

        if (RecLocation."Almacen Avanzado") then
            VJsonText := Inventario_Recurso_Almacen_Avanzado(xResourceNo, xLocation, xZone, xBin, xItemNo)
        else
            Error(lblErrorSinInventario);

        exit(VJsonText);

    end;



    procedure Inventario_Recurso_Almacen_Avanzado(xResourceNo: Text; xLocation: Text; xZone: Text; xBin: Text; xItemNo: Text): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        RecWarehouseJournalLine: Record "Warehouse Journal Line";

        RecLocation: Record Location;
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;
    begin

        if (xResourceNo = '') then ERROR(lblErrorRecurso);

        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        //Todo lo que no sea urgencia
        Clear(RecWarehouseJournalLine);
        RecWarehouseJournalLine.SetRange("Location Code", xLocation);
        RecWarehouseJournalLine.SetRange("Journal Template Name", RecLocation.AppInvJournalTemplateName);
        RecWarehouseJournalLine.SetRange("Journal Batch Name", RecLocation.AppInvJournalBatchName);

        if (xZone <> '') then
            RecWarehouseJournalLine.SetRange("Zone Code", xZone);
        if (xBin <> '') then
            RecWarehouseJournalLine.SetRange("Bin Code", xBin);
        if (xItemNo <> '') then
            RecWarehouseJournalLine.SetRange("Item No.", xItemNo);

        if RecWarehouseJournalLine.findset then begin
            repeat
                VJsonObjectInventario.Add('Location', RecWarehouseJournalLine."Location Code");
                VJsonObjectInventario.Add('LineNo', FormatoNumero(RecWarehouseJournalLine."Line No."));
                VJsonObjectInventario.Add('ItemNo', RecWarehouseJournalLine."Item No.");
                VJsonObjectInventario.Add('Description', RecWarehouseJournalLine.Description);
                VJsonObjectInventario.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWarehouseJournalLine."Item No.")));
                VJsonObjectInventario.Add('Zone', RecWarehouseJournalLine."Zone Code");
                VJsonObjectInventario.Add('Bin', RecWarehouseJournalLine."Bin Code");
                VJsonObjectInventario.Add('LotNo', RecWarehouseJournalLine."Lot No.");
                VJsonObjectInventario.Add('SerialNo', RecWarehouseJournalLine."Serial No.");
                VJsonObjectInventario.Add('PackagelNo', RecWarehouseJournalLine."Package No.");

                iTipoTrack := TipoSeguimientoProducto(RecWarehouseJournalLine."Item No.");

                case iTipoTrack of
                    0:
                        begin
                            VJsonObjectInventario.Add('TrackNo', '');
                            VJsonObjectInventario.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecWarehouseJournalLine."Serial No.");
                            VJsonObjectInventario.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecWarehouseJournalLine."Lot No.");
                            VJsonObjectInventario.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectInventario.Add('Date', FormatoFecha(RecWarehouseJournalLine."Registering Date"));
                VJsonObjectInventario.Add('Calculada', FormatoNumero(RecWarehouseJournalLine."Qty. (Calculated)"));
                VJsonObjectInventario.Add('Real', FormatoNumero(RecWarehouseJournalLine."Qty. (Phys. Inventory)"));
                VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecWarehouseJournalLine.Quantity));
                VJsonObjectInventario.Add('Unit', RecWarehouseJournalLine."Unit of Measure Code");

                VJsonObjectInventario.Add('Leido', FormatoBoolean(RecWarehouseJournalLine.Leido));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            until RecWarehouseJournalLine.Next() = 0;

        end;

        VJsonArrayInventario.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    procedure Validar_Linea_Inventario_Almacen_Avanzado(xTrackNo: Text; xBin: Text; xQuantity: Decimal; xItemNo: Text; xLocation: Text): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
        sTipo: Code[1];
    begin

        sTipo := Tipo_Dato(xTrackNo);

        CLEAR(RecWarehouseJournalLine);

        case sTipo of
            'L':
                RecWarehouseJournalLine.SetRange("Lot No.", xTrackNo);
            'S':
                RecWarehouseJournalLine.SetRange("Serial No.", xTrackNo);
            'P':
                RecWarehouseJournalLine.SetRange("Package No.", xTrackNo);
            'N':
                begin
                    IF (TipoSeguimientoProducto(xItemNo) > 0) THEN
                        ERROR(lblErrorTrackNo);
                    RecWarehouseJournalLine.SetRange("Item No.", xItemNo);
                end;

        end;

        RecWarehouseJournalLine.SetRange("Bin Code", xBin);

        IF (RecWarehouseJournalLine.FindFirst()) THEN begin

            RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory)", xQuantity);
            RecWarehouseJournalLine.Leido := true;
            RecWarehouseJournalLine.Modify();
        end else begin

            Agregar_Linea_Inventario_Almacen_Avanzado(xTrackNo, xBin, xQuantity, sTipo, xItemNo, xLocation);

        end;

    end;

    procedure Agregar_Linea_Inventario_Almacen_Avanzado(xTrackNo: Text; xBin: Text; xQuantity: Decimal; xTipo: Code[1]; xItemNo: Text; xLocation: Text): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecWarehouseJournalLineAux: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
    begin


        RecLocation.GET(xLocation);
        IF (RecLocation.AppInvJournalTemplateName = '') THEN ERROR(lblErrorDiarioInv);
        IF (RecLocation.AppInvJournalBatchName = '') THEN ERROR(lblErrorDiarioInv);

        clear(RecWarehouseJournalLineAux);
        RecWarehouseJournalLineAux.SETRANGE("Journal Template Name", RecLocation.AppInvJournalTemplateName);
        RecWarehouseJournalLineAux.SETRANGE("Journal Batch Name", RecLocation.AppInvJournalBatchName);
        if RecWarehouseJournalLineAux.FindLast() then
            NumeroLinea := RecWarehouseJournalLineAux."Line No." + 1001
        else
            Error(lblErrorSinInventario);
        ;

        //Se añade la línea nueva
        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(code, xBin);
        IF NOT RecBin.FindFirst() then Error(StrSubstNo(lblErrorUbicacion, xBin));

        RecWarehouseJournalLine.Init();
        RecWarehouseJournalLine."Journal Template Name" := RecLocation.AppInvJournalTemplateName;
        RecWarehouseJournalLine."Journal Batch Name" := RecLocation.AppInvJournalBatchName;
        NumeroLinea += 1000;
        RecWarehouseJournalLine."Line No." := NumeroLinea;
        RecWarehouseJournalLine."Registering Date" := Today;
        RecWarehouseJournalLine."Location Code" := RecBin."Location Code";
        RecWarehouseJournalLine."Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine.Validate("Bin Code", xBin);
        RecWarehouseJournalLine.Validate("Item No.", xItemNo);

        if (xTipo = '') then xTipo := Tipo_Dato(xTrackNo);

        case xTipo of
            'L':
                RecWarehouseJournalLine."Lot No." := xTrackNo;
            'S':
                RecWarehouseJournalLine."Serial No." := xTrackNo;
            'P':
                RecWarehouseJournalLine."Package No." := xTrackNo;
        //'N':
        //    Error(lblErrorTrackNo);
        end;

        RecWarehouseJournalLine."To Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine."To Bin Code" := RecBin.Code;

        Clear(RecLocation);
        RecLocation.Get(xLocation);
        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(code, RecLocation."Adjustment Bin Code");
        IF NOT RecBin.FindFirst() then Error(StrSubstNo(lblErrorUbicacion, RecLocation."Adjustment Bin Code"));

        RecWarehouseJournalLine."From Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine."From Bin Code" := RecBin.Code;
        RecWarehouseJournalLine."Source Code" := RecWarehouseJournalLineAux."Source Code"; //'INVFISALM';
        RecWarehouseJournalLine."Phys. Inventory" := true;
        RecWarehouseJournalLine."From Bin Type Code" := RecBin."Bin Type Code";
        RecWarehouseJournalLine."Whse. Document No." := RecWarehouseJournalLineAux."Whse. Document No.";
        RecWarehouseJournalLine."Whse. Document Type" := RecWarehouseJournalLine."Whse. Document Type"::"Whse. Phys. Inventory";
        RecWarehouseJournalLine.Validate("Qty. (Calculated)", 0);
        RecWarehouseJournalLine.Validate("Qty. (Calculated) (Base)", 0);
        RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory)", xQuantity);
        RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory) (Base)", xQuantity);
        RecWarehouseJournalLine."Qty. per Unit of Measure" := 1;
        RecWarehouseJournalLine."Entry Type" := RecWarehouseJournalLine."Entry Type"::"Positive Adjmt.";

        RecWarehouseJournalLine.Leido := true;

        RecWarehouseJournalLine.Insert();

    end;





    #endregion

    #region REGISTRO PEDIDOS INVENTARIO


    local procedure Objeto_Registro_Inventario(xOrderNo: code[20]; xRecordingNo: Integer): JsonObject
    var

        RecPhysInvtHeader: Record "Phys. Invt. Record Header";
        RecPhysInvtLine: Record "Phys. Invt. Record Line";

        RecItemReference: Record "Item Reference";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectInventory: JsonObject;
        VJsonArrayInventory: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;

        VJsonText: Text;

        CR: Char;
    begin

        CR := 13;

        RecWarehouseSetup.Get();

        clear(RecPhysInvtHeader);
        RecPhysInvtHeader.SetRange("Order No.", xOrderNo);
        RecPhysInvtHeader.SetRange("Recording No.", xRecordingNo);
        if RecPhysInvtHeader.FindFirst() then;

        VJsonObjectInventory.Add('OrderNo', RecPhysInvtHeader."Order No.");
        VJsonObjectInventory.Add('RecordingNo', FormatoNumero(RecPhysInvtHeader."Recording No."));
        VJsonObjectInventory.Add('Location', RecPhysInvtHeader."Location Code");
        VJsonObjectInventory.Add('Date', FormatoFecha(RecPhysInvtHeader."Date Recorded"));
        VJsonObjectInventory.Add('Description', RecPhysInvtHeader.Description);
        VJsonObjectInventory.Add('Status', FORMAT(RecPhysInvtHeader.Status));

        Clear(RecPhysInvtLine);
        RecPhysInvtLine.SetRange("Order No.", RecPhysInvtHeader."Order No.");
        RecPhysInvtLine.SetRange("Recording No.", RecPhysInvtHeader."Recording No.");
        RecPhysInvtLine.SetRange(Recorded, true);
        if RecPhysInvtLine.FindFirst() then
            VJsonObjectInventory.Add('Partially', FormatoBoolean(true))
        else
            VJsonObjectInventory.Add('Partially', FormatoBoolean(false));

        exit(VJsonObjectInventory);

    end;

    procedure Lineas_Registro_Inventario_Recurso(xResourceNo: Text; xLocation: Text; xOrderNo: Text; xRecordingNo: Integer): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";

        RecLocation: Record Location;
        RecRecurso: Record Resource;
        vJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;
    begin

        RecRecurso.Get(xResourceNo);
        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        //Todo lo que no sea urgencia
        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", xOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", xRecordingNo);
        if RecPhyInvetRecordLine.findset then begin
            repeat
                VJsonObjectInventario.Add('OrderNo', RecPhyInvetRecordLine."Order No.");
                VJsonObjectInventario.Add('RecordingNo', RecPhyInvetRecordLine."Recording No.");
                VJsonObjectInventario.Add('LineNo', FormatoNumero(RecPhyInvetRecordLine."Line No."));

                VJsonObjectInventario.Add('Location', RecPhyInvetRecordLine."Location Code");
                VJsonObjectInventario.Add('ItemNo', RecPhyInvetRecordLine."Item No.");
                VJsonObjectInventario.Add('Description', RecPhyInvetRecordLine.Description);
                VJsonObjectInventario.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecPhyInvetRecordLine."Item No.")));
                VJsonObjectInventario.Add('Zone', '');
                VJsonObjectInventario.Add('Bin', RecPhyInvetRecordLine."Bin Code");
                VJsonObjectInventario.Add('LotNo', RecPhyInvetRecordLine."Lot No.");
                VJsonObjectInventario.Add('SerialNo', RecPhyInvetRecordLine."Serial No.");
                VJsonObjectInventario.Add('PackagelNo', '');

                iTipoTrack := TipoSeguimientoProducto(RecPhyInvetRecordLine."Item No.");

                case iTipoTrack of
                    0:
                        begin
                            VJsonObjectInventario.Add('TrackNo', '');
                            VJsonObjectInventario.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecPhyInvetRecordLine."Serial No.");
                            VJsonObjectInventario.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecPhyInvetRecordLine."Lot No.");
                            VJsonObjectInventario.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectInventario.Add('Date', FormatoFecha(RecPhyInvetRecordLine."Date Recorded"));

                if RecRecurso."Ver cantidad inventario" then begin
                    VJsonObjectInventario.Add('Calculada', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    VJsonObjectInventario.Add('Real', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                end else begin
                    if (RecPhyInvetRecordLine.Recorded) then begin
                        VJsonObjectInventario.Add('Calculada', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                        VJsonObjectInventario.Add('Real', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                        VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    end else begin
                        VJsonObjectInventario.Add('Calculada', FormatoNumero(0));
                        VJsonObjectInventario.Add('Real', FormatoNumero(0));
                        VJsonObjectInventario.Add('Diferencia', FormatoNumero(0));
                    end;

                end;


                VJsonObjectInventario.Add('Unit', RecPhyInvetRecordLine."Unit of Measure Code");

                VJsonObjectInventario.Add('Leido', FormatoBoolean(RecPhyInvetRecordLine.Recorded));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            until RecPhyInvetRecordLine.Next() = 0;

        end;

        VJsonArrayInventario.WriteTo(vJsonText);
        exit(vJsonText);

    end;

    procedure Agregar_Linea_Registro_Inventario(xTrackType: Text; xTrackNo: Text; xBin: Text; xQuantity: Decimal; xItemNo: Text; xLocation: Text; xOrderNo: Text; xRecordingNo: Integer)
    var


        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";
        RecPhyInvetRecordLineAux: Record "Phys. Invt. Record Line";

        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";

        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
    begin

        RecLocation.GET(xLocation);

        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", xOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", xRecordingNo);
        RecPhyInvetRecordLine.SetRange("Item No.", xItemNo);

        if (xBin <> '') then
            RecPhyInvetRecordLine.SetRange("Bin Code", xBin);

        case xTrackType of
            'L':
                RecPhyInvetRecordLine.SetRange("Lot No.", xTrackNo);
            'S':
                RecPhyInvetRecordLine.SetRange("Serial No.", xTrackNo);
        end;

        if RecPhyInvetRecordLine.FindFirst() then begin
            IF (RecLocation.SumarCantidad) then begin
                if (RecPhyInvetRecordLine.Recorded) then
                    RecPhyInvetRecordLine.Quantity += xQuantity
                else
                    RecPhyInvetRecordLine.Quantity := xQuantity;
            end else
                RecPhyInvetRecordLine.Quantity := xQuantity;
            RecPhyInvetRecordLine.Recorded := true;
            RecPhyInvetRecordLine.Modify();
        end else begin

            NumeroLinea := 5000;
            clear(RecPhyInvetRecordLineAux);
            RecPhyInvetRecordLineAux.SetRange("Order No.", xOrderNo);
            RecPhyInvetRecordLineAux.SetRange("Recording No.", xRecordingNo);
            if RecPhyInvetRecordLineAux.FindLast() then
                NumeroLinea := RecPhyInvetRecordLineAux."Line No." + 10000;

            RecPhyInvetRecordLine.Init();
            RecPhyInvetRecordLine.Validate("Order No.", xOrderNo);
            RecPhyInvetRecordLine.Validate("Recording No.", xRecordingNo);
            RecPhyInvetRecordLine.Validate("Line No.", NumeroLinea);
            RecPhyInvetRecordLine.Validate("Item No.", xItemNo);

            if (xBin <> '') then
                RecPhyInvetRecordLine.Validate("Bin Code", xBin);

            case xTrackType of
                'L':
                    begin
                        Clear(RecLotNo);
                        RecLotNo.SetRange("Lot No.", xTrackNo);
                        RecLotNo.SetRange("Item No.", xItemNo);
                        if not RecLotNo.FindFirst() then Error(StrSubstNo(lblErrorLoteInternoNoExiste, xTrackNo));
                        RecPhyInvetRecordLine.Validate("Lot No.", xTrackNo);
                    end;

                'S':
                    begin
                        Clear(RecSerialNo);
                        RecSerialNo.SetRange("Serial No.", xTrackNo);
                        RecSerialNo.SetRange("Item No.", xItemNo);
                        if not RecSerialNo.FindFirst() then Error(StrSubstNo(lblErrorSerieInternoNoExiste, xTrackNo));
                        RecPhyInvetRecordLine.Validate("Serial No.", xTrackNo);
                    end;
            end;

            RecPhyInvetRecordLine.Validate(Quantity, xQuantity);
            RecPhyInvetRecordLine."Recorded Without Order" := true;
            RecPhyInvetRecordLine.Recorded := true;

            RecPhyInvetRecordLine.Insert();

        end;

    end;

    #endregion

    #region AJUSTE


    procedure WsAjustar(xJson: Text): Text
    var

        RecLocation: Record Location;
        RecWarehouseSetup: Record "Warehouse Setup";
        QueryContPaquete: Query "Lot Numbers by Bin";

        VJsonObjectDatos: JsonObject;

        lContenedor: Text;
        lAlmacen: Text;

        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";

        lUbicadionDesde: Text;
        lUbicacionHasta: Text;
        lCantidad: Decimal;
        lResource: Text;
        lItemNo: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        newPackageNo: Text;
        ltipo: Text;
        lTrackNo: Text;
        lPositivo: Boolean;
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            Error('Respuesta no valida. Se esperaba un Json');

        lContenedor := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lTipo := DatoJsonTexto(VJsonObjectDatos, 'Tipo');

        lItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        lUbicadionDesde := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');
        lCantidad := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');
        lResource := DatoJsonTexto(VJsonObjectDatos, 'Resource');
        lAlmacen := DatoJsonTexto(VJsonObjectDatos, 'Location');
        lLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        lSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        lPackageNo := DatoJsonTexto(VJsonObjectDatos, 'PackageNo');

        lPositivo := DatoJsonBoolean(VJsonObjectDatos, 'Positive');

        IF (lLotNo <> '') then begin
            Clear(RecLotNo);
            RecLotNo.SetRange("Item No.", lItemNo);
            RecLotNo.SetRange("Lot No.", lLotNo);
            if not RecLotNo.FindFirst() then
                Crear_Lote(lLotNo, lItemNo, lCantidad, '', '', 0D);
        end;

        IF (lSerialNo <> '') then begin
            Clear(RecSerialNo);
            RecSerialNo.SetRange("Item No.", lItemNo);
            RecSerialNo.SetRange("Serial No.", lSerialNo);
            if not RecSerialNo.FindFirst() then
                Crear_Serie(lSerialNo, lItemNo, lCantidad, '', '');
        end;

        RecLocation.Get(lAlmacen);
        IF RecLocation."Almacen Avanzado" then
            Diario_Almacen(lLotNo, lSerialNo, lItemNo, lCantidad, lUbicadionDesde, lAlmacen, lPositivo, 'APP_AJ')
        ELSE
            Diario_Producto(lAlmacen, lUbicadionDesde, lItemNo, lCantidad, lLotNo, lSerialNo, lPositivo, 'APP_AJ');

        exit('OK');

    end;




    local procedure Diario_Almacen(xLote: Code[50]; xSerie: Code[50]; xReferencia: Code[20]; xCantidad: Decimal; xUbicacion: Code[20]; xLocation: Code[10]; xPositivo: Boolean; xDoc: Text)
    var
        RecLocation: Record Location;
        LRecWarehouseJournalLine: Record "Warehouse Journal Line";
        LRecItemTracking: Record "Whse. Item Tracking Line";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecBin: Record Bin;
        RecBinAjus: Record Bin;

        vNumeroLinea: Integer;
        vNumeroLineaTr: Integer;

        vTemplate: Text;
        vBacth: Text;

    begin

        Clear(RecLocation);
        RecLocation.get(xLocation);
        if RecLocation.AppWhseJournalTemplateName = '' then ERROR(lblErrorDiarioAlm);
        if RecLocation.AppWhseJournalBatchName = '' then ERROR(lblErrorDiarioAlm);
        //vTemplate := 'AJUST';
        //vBacth := 'GENERICO';

        vTemplate := RecLocation.AppWhseJournalTemplateName;
        vBacth := RecLocation.AppWhseJournalBatchName;

        LRecWarehouseJournalLine.RESET;

        LRecWarehouseJournalLine.SetRange("Journal Template Name", vTemplate);
        LRecWarehouseJournalLine.SetRange("Journal Batch Name", vBacth);
        IF (LRecWarehouseJournalLine.FindLast()) THEN
            vNumeroLinea := LRecWarehouseJournalLine."Line No." + 10001
        ELSE
            vNumeroLinea := 60001;

        if not xPositivo then
            xCantidad := -xCantidad;

        //Comprobar si ya está creado
        /*Clear(LRecItemTracking);
        LRecItemTracking.SetRange("Item No.", xReferencia);
        LRecItemTracking.SetRange("Location Code", xLocation);
        IF xCantidad < 0 THEN
            LRecItemTracking.SetRange("Qty. to Handle", -xCantidad)
        else
            LRecItemTracking.SetRange("Qty. to Handle", -xCantidad);
        LRecItemTracking.SetRange("Lot No.", xLote);
        LRecItemTracking.SetRange("Serial No.", xSerie);
        if LRecItemTracking.FindFirst() then ERROR('Ya existe el registro.\\Lote: %1 \Serie: %2', xLote, xSerie);
        */


        //Buscar ubicación
        Clear(RecBin);
        RecBin.SetRange("Location Code", xLocation);
        RecBin.SetRange(Code, xUbicacion);
        IF not RecBin.FindFirst() then error(StrSubstNo(lblErrorUbicacion, xUbicacion));

        LRecWarehouseJournalLine.RESET;
        LRecWarehouseJournalLine.INIT;
        LRecWarehouseJournalLine.VALIDATE("Journal Template Name", vTemplate);
        LRecWarehouseJournalLine.VALIDATE("Journal Batch Name", vBacth);
        LRecWarehouseJournalLine."Whse. Document No." := xDoc;
        LRecWarehouseJournalLine.VALIDATE("Location Code", xLocation);
        LRecWarehouseJournalLine.SetUpNewLine(LRecWarehouseJournalLine);
        LRecWarehouseJournalLine."Line No." := vNumeroLinea;
        LRecWarehouseJournalLine.VALIDATE("Registering Date", Today);
        LRecWarehouseJournalLine.VALIDATE("Item No.", xReferencia);

        LRecWarehouseJournalLine.VALIDATE(Quantity, xCantidad);

        LRecWarehouseJournalLine."Zone Code" := RecBin."Zone Code";
        LRecWarehouseJournalLine."Bin Code" := xUbicacion;

        RecLocation.Get(xLocation);

        //Buscar ubicación
        Clear(RecBinAjus);
        RecBinAjus.SetRange(Code, RecLocation."Adjustment Bin Code");
        IF not RecBinAjus.FindFirst() then Error('No se ha encontrado la ubicación %1', RecBinAjus);

        IF xCantidad > 0 THEN begin

            LRecWarehouseJournalLine."From Zone Code" := RecBinAjus."Zone Code";
            LRecWarehouseJournalLine."From Bin Code" := RecBinAjus.Code;

            LRecWarehouseJournalLine."To Zone Code" := RecBin."Zone Code";
            LRecWarehouseJournalLine."To Bin Code" := xUbicacion;

        end ELSE begin
            LRecWarehouseJournalLine."To Zone Code" := RecBinAjus."Zone Code";
            LRecWarehouseJournalLine."To Bin Code" := RecBinAjus.Code;

            LRecWarehouseJournalLine."From Zone Code" := RecBin."Zone Code";
            LRecWarehouseJournalLine."From Bin Code" := xUbicacion;
        end;

        LRecWarehouseJournalLine."User ID" := USERID;

        IF LRecWarehouseJournalLine.INSERT THEN;

        vNumeroLineaTr := 70001;
        LRecItemTracking.RESET;
        IF LRecItemTracking.FINDLAST THEN;
        vNumeroLineaTr += LRecItemTracking."Entry No.";

        //ES NECESARIO AGREGAR LA INFORMACION DEL LOTE
        LRecItemTracking.INIT;
        LRecItemTracking."Entry No." := vNumeroLineaTr;
        LRecItemTracking."Item No." := xReferencia;
        LRecItemTracking."Location Code" := xLocation;
        IF xCantidad < 0 THEN BEGIN
            LRecItemTracking."Qty. to Handle" := -xCantidad;
            LRecItemTracking."Quantity (Base)" := -xCantidad;
            LRecItemTracking."Qty. to Handle (Base)" := -xCantidad;
        END ELSE BEGIN
            LRecItemTracking."Qty. to Handle" := xCantidad;
            LRecItemTracking."Quantity (Base)" := xCantidad;
            LRecItemTracking."Qty. to Handle (Base)" := xCantidad;
        END;

        LRecItemTracking."Source Ref. No." := vNumeroLinea;
        LRecItemTracking."Source Type" := 7311;
        LRecItemTracking."Source Batch Name" := vTemplate;
        LRecItemTracking."Source ID" := vBacth;
        LRecItemTracking."Lot No." := xLote;
        LRecItemTracking."Serial No." := xSerie;
        LRecItemTracking."New Package No." := xDoc;
        LRecItemTracking.INSERT(TRUE);

        //REGISTRAR

        LRecWarehouseJournalLine.RESET;
        LRecWarehouseJournalLine.SETRANGE("Journal Template Name", vTemplate);
        LRecWarehouseJournalLine.SETRANGE("Journal Batch Name", vBacth);
        LRecWarehouseJournalLine.SETRANGE("Location Code", xLocation);
        LRecWarehouseJournalLine.SETRANGE("Line No.", vNumeroLinea);
        IF LRecWarehouseJournalLine.FINDFIRST THEN
            CODEUNIT.RUN(CODEUNIT::"Whse. Jnl.-Register Batch", LRecWarehouseJournalLine);

        Diario_Producto(xLocation, xUbicacion, xReferencia, xCantidad, xLote, xSerie, xPositivo, xDoc);

    end;

    local procedure Diario_Producto(xLocation: Text; xBin: Text; xReferencia: Text; xCantidad: Decimal; xLote: Text; xSerie: Text; xPositive: boolean; xDoc: Text)
    var
        RecLocation: Record Location;
        //RecWarehouseSetup: Record "Warehouse Setup";
        LRecItemJournalLine: Record "Item Journal Line";
        LRecReservationEntry: Record "Reservation Entry";
        vNumeroLinea: Integer;
        vNumeroLineaTr: Integer;
        vTemplate: Text;
        vBacth: Text;
        ItemCost: record Item;
    begin

        Clear(RecLocation);
        RecLocation.get(xLocation);
        if RecLocation.AppItemJournalTemplateName = '' then ERROR(lblErrorDiarioAlm);
        if RecLocation.AppItemJournalBatchName = '' then ERROR(lblErrorDiarioAlm);

        vTemplate := RecLocation.AppItemJournalTemplateName;
        vBacth := RecLocation.AppItemJournalBatchName;
        //vTemplate := 'PRODUCTO';
        //vBacth := 'GENERICO';

        LRecItemJournalLine.RESET;

        LRecItemJournalLine.SetRange("Journal Template Name", vTemplate);
        LRecItemJournalLine.SetRange("Journal Batch Name", vBacth);
        IF (LRecItemJournalLine.FindLast()) THEN
            vNumeroLinea := LRecItemJournalLine."Line No." + 10001
        ELSE
            vNumeroLinea := 60001;


        LRecItemJournalLine.RESET;
        LRecItemJournalLine.INIT;

        LRecItemJournalLine.VALIDATE("Journal Template Name", vTemplate);
        LRecItemJournalLine.VALIDATE("Journal Batch Name", vBacth);

        //LRecItemJournalLine.SetUpNewLine(LRecItemJournalLine);
        //Buscamos el número de línea
        LRecItemJournalLine."Line No." := vNumeroLinea;

        LRecItemJournalLine.VALIDATE("Posting Date", Today);
        IF xPositive THEN BEGIN
            LRecItemJournalLine.VALIDATE("Entry Type", LRecItemJournalLine."Entry Type"::"Positive Adjmt.")
        END ELSE BEGIN
            LRecItemJournalLine.VALIDATE("Entry Type", LRecItemJournalLine."Entry Type"::"Negative Adjmt.");
            xCantidad := xCantidad * -1;
        END;

        LRecItemJournalLine.VALIDATE("Item No.", xReferencia);
        LRecItemJournalLine.VALIDATE("Location Code", xLocation);
        LRecItemJournalLine."Document No." := xDoc;
        LRecItemJournalLine.VALIDATE(Quantity, xCantidad);

        if (xBin <> '') then
            LRecItemJournalLine.VALIDATE(LRecItemJournalLine."Bin Code", xBin);

        LRecItemJournalLine.VALIDATE("Invoiced Quantity", xCantidad);
        LRecItemJournalLine."Warehouse Adjustment" := TRUE;
        //PX221123 METEMOS COSTE ESTANDAR
        IF ItemCost.GET(LRecItemJournalLine."Item No.") and (itemCost."Standard Cost" <> 0) then
            LRecItemJournalLine.VALIDATE("Unit Cost", ItemCost."Standard Cost");
        //PX221123             

        IF LRecItemJournalLine.INSERT THEN;

        //ES NECESARIO AGREGAR LA INFORMACION DEL LOTE
        vNumeroLineaTr := 70001;
        IF LRecReservationEntry.FINDLAST THEN
            vNumeroLineaTr := LRecReservationEntry."Entry No." + 100;

        LRecReservationEntry.INIT;
        LRecReservationEntry."Entry No." := vNumeroLineaTr;
        LRecReservationEntry."Item No." := xReferencia;
        LRecReservationEntry."Location Code" := xLocation;

        IF xPositive THEN BEGIN
            LRecReservationEntry."Quantity (Base)" := xCantidad;
            LRecReservationEntry."Qty. to Handle (Base)" := xCantidad;
            LRecReservationEntry.Quantity := xCantidad;
            LRecReservationEntry."Qty. to Invoice (Base)" := xCantidad;
        END ELSE BEGIN
            LRecReservationEntry."Quantity (Base)" := -xCantidad;
            LRecReservationEntry."Qty. to Handle (Base)" := -xCantidad;
            LRecReservationEntry.Quantity := -xCantidad;
            LRecReservationEntry."Qty. to Invoice (Base)" := -xCantidad;
        END;
        LRecReservationEntry."Reservation Status" := LRecReservationEntry."Reservation Status"::Prospect;
        LRecReservationEntry."Source Ref. No." := vNumeroLinea;
        LRecReservationEntry."Created By" := USERID;
        LRecReservationEntry."Source Type" := 83;
        IF xPositive THEN
            LRecReservationEntry."Source Subtype" := 2
        ELSE
            LRecReservationEntry."Source Subtype" := 3;
        LRecReservationEntry.Positive := TRUE;
        LRecReservationEntry."Source Batch Name" := vBacth;
        LRecReservationEntry."Source ID" := vTemplate;


        LRecReservationEntry."Lot No." := xLote;
        LRecReservationEntry."Serial No." := xSerie;
        if (xSerie = '') then
            LRecReservationEntry."Item Tracking" := LRecReservationEntry."Item Tracking"::"Lot No."
        else
            LRecReservationEntry."Item Tracking" := LRecReservationEntry."Item Tracking"::"Lot and Serial No.";

        LRecReservationEntry."New Package No." := xDoc;

        LRecReservationEntry.INSERT(TRUE);


        //REGISTRAR
        LRecItemJournalLine.RESET;
        LRecItemJournalLine.SETRANGE("Journal Template Name", vTemplate);
        LRecItemJournalLine.SETRANGE("Journal Batch Name", vBacth);
        LRecItemJournalLine.SETRANGE("Location Code", xLocation);
        LRecItemJournalLine.SETRANGE("Line No.", vNumeroLinea);
        IF LRecItemJournalLine.FINDFIRST THEN
            CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post Batch", LRecItemJournalLine);


    end;




    #endregion

    #region FUNCIONES BC



    local procedure Comprobar_Stock_Ubicacion(xItemNo: Code[20]; xLotNo: Code[50]; xSerialNo: Code[50]; xCantidad: Decimal; xBinCode: Code[50])
    var
        QueryLotInventory: Query "Lot Numbers by Bin";
    begin

        //Inventario por ubicación
        Clear(QueryLotInventory);
        QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', xItemNo);
        QueryLotInventory.SetFilter(QueryLotInventory.Bin_Code, '=%1', xBinCode);
        QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty_Base, '>%1', xCantidad);

        if (xLotNo <> '') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xLotNo);
        if (xSerialNo <> '') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xSerialNo);

        QueryLotInventory.Open();
        IF NOT QueryLotInventory.READ THEN ERROR(lblErrorSinStock + xBinCode);

        QueryLotInventory.Close();

        exit;

    end;




    /// <summary>
    /// Determina si es un Lote(L), Un Serie(S),Paquete(P), Nulo(N), Item(I)
    /// </summary>
    local procedure Tipo_Dato(var xTrackNo: Text): Code[1]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        RecItem: Record Item;
        sRefCruzada: Code[50];
    begin

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit('S');

        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit('L');

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", xTrackNo);
        if RecPackage.FindFirst() then exit('P');

        Clear(RecItem);
        RecItem.SetRange("No.", xTrackNo);
        if RecItem.FindFirst() then exit('I');

        sRefCruzada := Buscar_Item_De_Referencia_Cruzada(xTrackNo);
        if sRefCruzada <> '' then begin
            xTrackNo := sRefCruzada;
            exit('I');
        end;


        exit('N');
    end;

    local procedure Item_Tipo_Dato(xTrackNo: Text): Code[50]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
    begin

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit(RecSerialNo."Item No.");

        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit(RecLotNo."Item No.");

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", xTrackNo);
        if RecPackage.FindFirst() then exit(RecLotNo."Item No.");

        exit('');
    end;

    local procedure Existe_Referencia(xItemNo: Text; xAnalizarSeg: Boolean): Boolean
    var
        RecItem: Record Item;
    begin
        Clear(RecItem);
        RecItem.SetRange("No.", xItemNo);
        if not RecItem.FindFirst() then begin
            Error(StrSubstNo(lblErrorReferencia, xItemNo));
        end;

        if (xAnalizarSeg) then begin
            //Comprobar que tenga cod. seguimiento producto
            if RecItem."Item Tracking Code" = '' THEN Error(StrSubstNo(lblErrorCodSeguimiento, xItemNo));
        end;

    end;

    local procedure Existe_Lote(xLotNo: Text; xItemNo: Text): Boolean
    var
        RecLotNo: Record "Lot No. Information";
    begin
        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xLotNo);
        if not RecLotNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Existe_Serie(xSerialNo: Text): Boolean
    var
        RecSerialNo: Record "Serial No. Information";
    begin
        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xSerialNo);
        if not RecSerialNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Existe_Paquete(xPackageNo: Text): Boolean
    var
        RecPackageNo: Record "Package No. Information";
    begin
        Clear(RecPackageNo);
        RecPackageNo.SetRange("Package No.", xPackageNo);
        if not RecPackageNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Ubicacion_Paquete(xPackageNo: Text; xLocation: Text): Text
    var
        QueryLotInventory: Query "Lot Numbers by Bin";
    begin

        Clear(QueryLotInventory);
        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, xLocation);
        QueryLotInventory.SetFilter(QueryLotInventory.Package_No, xPackageNo);

        QueryLotInventory.Open();
        if QueryLotInventory.READ then
            exit(QueryLotInventory.Bin_Code)
        else
            exit('');


    end;


    local procedure Buscar_Item_De_Referencia_Cruzada(xCode: Code[50]): Code[50]
    var
        RecItemReference: Record "Item Reference";
    begin
        clear(RecItemReference);
        RecItemReference.SetRange(RecItemReference."Reference No.", xCode);

        IF RecItemReference.FindFirst() then
            exit(RecItemReference."Item No.")
        ELSE
            exit('');
    end;


    /// <summary>
    /// Busca Referencia Cruzada
    /// </summary>
    /// <param name="xItem">Referencia</param>
    /// <param name="xVendor">Provedor</param>
    local procedure Buscar_Referencia_Cruzada(xItem: Code[50]; xVendor: Code[50]): Code[50]
    var
        RecItemReference: Record "Item Reference";
    begin
        clear(RecItemReference);
        RecItemReference.SetRange(RecItemReference."Item No.", xItem);
        RecItemReference.SetFilter("Ending Date", '%1|>%2', 0D, WorkDate());
        if (xVendor <> '') then begin
            RecItemReference.SetRange("Reference Type", RecItemReference."Reference Type"::Vendor);
            RecItemReference.SetRange("Reference Type No.", xVendor);
        END ELSE
            RecItemReference.SetRange("Reference Type", RecItemReference."Reference Type"::"Bar Code");

        IF RecItemReference.FindFirst() then
            exit(RecItemReference."Reference No.")
        ELSE
            exit('');
    end;

    procedure Descripcion_ItemNo(xItem: Code[50]): Text
    var
        RecItem: Record Item;
    begin
        Clear(RecItem);
        RecItem.SetRange("No.", xItem);
        if RecItem.FindFirst() then
            Exit(RecItem.Description)
        else
            Exit('');
    end;

    ///<summary>1: Materia Prima - 2: Semielaborado - 3: Producto Terminado</summary>    
    procedure Base_Numero_Contenedor_b(xTipo: Integer; xItemNo: Text): Text
    var
        RecLotNoInf: Record "Lot No. Information";
        RecItem: Record Item;
        cuNoSeriesManagement: Codeunit NoSeriesManagement;
        TxtContenedor: Text;
        xInicial: Text;
        Formato: Text;
        xNumero: Integer;
        sufijo: Text;
        SufijoNumSerie: Text;
    begin

        TxtContenedor := '';

        if (xItemNo = '') then error(lblErrorSinReferencia);
        RecItem.Get(xItemNo);
        if (RecItem."Lot Nos." = '') then error(lblErrorNSerieLote);

        TxtContenedor := cuNoSeriesManagement.GetNextNo(RecItem."Lot Nos.", WorkDate, true);

        Clear(RecLotNoInf);
        RecLotNoInf.SetRange("Lot No.", TxtContenedor);
        if RecLotNoInf.FindFirst() then ERROR(lblErrorLoteInterno);


        exit(TxtContenedor);
    end;


    /*[TryFunction]
    local procedure App_Location(VAR xLocation: Text)
    var
        RecWarehouseSetup: Record "Warehouse Setup";
    begin
        RecWarehouseSetup.GET();
        if (RecWarehouseSetup."App Location" = '') then
            Error(lblErrorAlmacen)
        else
            xLocation := RecWarehouseSetup."App Location";


    end;*/

    /// <summary>
    /// AnalizarSeguimientoProducto.
    /// </summary>
    /// <param name="pItemNo">code[20].</param>
    /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
    procedure TipoSeguimientoProducto(pItemNo: code[20]) rResultado: Integer;
    var
        EnumTracking: Enum "Item Tracking Entry Type";
    begin
        EnumTracking := AnalizarSeguimientoProducto(pItemNo);

        Case EnumTracking of
            EnumTracking::"Lot No.":
                rResultado := 1; //Lote
            EnumTracking::"Serial No.":
                rResultado := 2; //Serie
            EnumTracking::"Lot and Serial No.":
                rResultado := 3; //Lote y serie
            EnumTracking::"Lot and Package No.":
                rResultado := 4; //Lote y paquete
            EnumTracking::"Serial and Package No.":
                rResultado := 5; //Serie y paquete
            EnumTracking::"Lot and Serial and Package No.":
                rResultado := 6; //Lote, serie y paquete
            else
                rResultado := 0; //nada
        End

    end;

    procedure AnalizarSeguimientoProducto(pItemNo: code[20]) rResultado: Enum "Item Tracking Entry Type";
    var
        tItem: Record Item;
        tItemTrackingCode: Record "Item Tracking Code";
        SiLote: Boolean;
        SiSerie: Boolean;
        SiPack: Boolean;
        lblErrorItem: Label 'The item %1 does not exist', comment = 'ESP="El producto %1 no existe"';
    begin

        rResultado := rResultado::None;
        //Primero recuperamos y comprobaremos que el producto existe
        IF NOT tItem.GET(pItemNo) THEN
            ERROR(StrSubstNo(lblErrorItem, pItemNo));

        //Recuperamos el seguimiento del producto
        Silote := FALSE;
        SIserie := FALSE;
        SiPack := FALSE;
        IF tItem."Item Tracking Code" <> '' THEN BEGIN
            IF tItemTrackingCode.GET(tItem."Item Tracking Code") THEN BEGIN
                Silote := tItemTrackingCode."Lot Warehouse Tracking";
                Siserie := tItemTrackingCode."SN Warehouse Tracking";
                SiPack := tItemTrackingCode."Package Warehouse Tracking";
            END;

            IF (NOT SiLote) AND (NOT SiSerie) AND (NOT SiPack) THEN
                rResultado := rResultado::None
            ELSE
                IF SiLote AND SiSerie AND SiPack THEN
                    rResultado := rResultado::"Lot and Serial and Package No."
                ELSE
                    IF SiLote AND SiSerie AND (NOT SiPack) THEN
                        rResultado := rResultado::"Lot and Serial No."
                    ELSE
                        IF SiLote AND (NOT SiSerie) AND SiPack THEN
                            rResultado := rResultado::"Lot and Package No."
                        ELSE
                            IF SiLote AND (NOT SiSerie) AND (NOT SiPack) THEN
                                rResultado := rResultado::"Lot No."
                            ELSE
                                IF (NOT SiLote) AND SiSerie AND SiPack THEN
                                    rResultado := rResultado::"Serial and Package No."
                                ELSE
                                    IF (NOT SiLote) AND SiSerie AND (NOT SiPack) THEN
                                        rResultado := rResultado::"Serial No."
                                    ELSE
                                        IF (NOT SiLote) AND (NOT SiSerie) AND SiPack THEN
                                            rResultado := rResultado::"Package No.";

        end;
    END;


    procedure Tiene_Caducidad(xItemNo: Code[20]): Boolean
    var
        RecItem: Record Item;
        RecItemTrackingCode: Record "Item Tracking Code";
    begin
        Clear(RecItem);
        RecItem.Get(xItemNo);
        if (RecItem."Item Tracking Code" <> '') then begin
            clear(RecItemTrackingCode);
            RecItemTrackingCode.Get(RecItem."Item Tracking Code");
            exit(RecItemTrackingCode."Man. Expir. Date Entry Reqd.")
        end else
            exit(false);
    end;


    #endregion

    #region DATOS JSON

    local procedure DatoJsonTexto(xObjeto: JsonObject; xNodo: Text): text
    var
        VJsonTokenParte: JsonToken;
        jVariable: Text;
    begin
        jVariable := '';
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit('')
            else begin
                jVariable := VJsonTokenParte.AsValue().AsText();
                exit(jVariable);
            end;
        end else begin
            exit('');
        end;
    end;


    local procedure DatoArrayJsonTexto(xObjeto: JsonObject; xNodo: Text): JsonArray
    var
        VJsonTokenParte: JsonToken;
        vArray: JsonArray;
    begin

        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            vArray := VJsonTokenParte.AsArray();
            exit(vArray);
        end else begin
            exit(vArray);
        end;
    end;


    local procedure DatoJsonDecimal(xObjeto: JsonObject; xNodo: Text): Decimal
    var
        VJsonTokenParte: JsonToken;
        jVariable: Decimal;
    begin
        jVariable := 0;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsDecimal();
                exit(jVariable);
            end;
        end else begin
            exit(0);
        end;

    end;

    local procedure DatoJsonInteger(xObjeto: JsonObject; xNodo: Text): Integer
    var
        VJsonTokenParte: JsonToken;
        jVariable: Integer;
    begin
        jVariable := 0;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsInteger();
                exit(jVariable);
            end;
        end else begin
            exit(0);
        end;
    end;

    local procedure DatoJsonDate(xObjeto: JsonObject; xNodo: Text): Date
    var
        VJsonTokenParte: JsonToken;
        jVariable: Date;
    begin
        jVariable := 0D;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0D)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsDate();
                exit(jVariable);
            end;
        end else begin
            exit(0D);
        end;
    end;


    local procedure DatoJsonBoolean(xObjeto: JsonObject; xNodo: Text): Boolean
    var
        VJsonTokenParte: JsonToken;
        vTexto: Text;
        jVariable: Boolean;
    begin
        jVariable := false;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(jVariable)
            else begin
                vTexto := VJsonTokenParte.AsValue().AsText();
                if (UpperCase(vTexto) = 'TRUE') OR (UpperCase(vTexto) = 'YES') then
                    jVariable := true;
                exit(jVariable);
            end;
        end else begin
            exit(jVariable);
        end;
    end;

    #endregion DATOS JSON

    #region FUNCIONES

    local procedure QuitarPunto(xValor: text): Text
    begin
        exit(xValor.Replace('.', ''));
    end;

    local procedure FormatoBoolean(xCampo: Boolean): Text
    var

    begin
        if xCampo then
            exit('True')
        else
            exit('False')
    end;

    local procedure FormatoFecha(xCampo: DateTime): Text
    var
    begin
        //EXIT(Format(xCampo, 10, '<day,2>/<month,2>/<year4>'));
        EXIT(Format(xCampo, 0, 9))
    end;

    local procedure FormatoFecha(xCampo: Date): Text
    var
    begin
        if xCampo <> 0D THEN
            //EXIT(Format(xCampo, 10, '<day,2>/<month,2>/<year4>'))
            EXIT(Format(xCampo, 0, 9))
        ELSE
            EXIT(Format('01/01/2000', 0, 9));
    end;

    local procedure FormatoNumero(xCampo: Decimal): Text
    var
    begin
        EXIT(Format(xCampo, 0, 9));
    end;

    local procedure FormatoNumero(xCampo: Integer): Text
    var
    begin
        EXIT(Format(xCampo, 0, 9));
        //EXIT(QuitarPunto(Format(xCampo)));
    end;

    local procedure QuitarCaracteresRaros(xOriginal: Text) xFinal: Text
    var
        Filtro1: Text;
        Filtro2: Text;
    begin
        Filtro1 := '()"&´/'; //'ÁÀÉÈÍÌÓÒÚÙÜ()"&´/'
        Filtro2 := '     -'; //'ÁÀÉÈÍÌÓÒÚÙÜ()"&´/'

        xFinal := CONVERTSTR(xOriginal, Filtro1, Filtro2);
    end;

    #endregion FUNCIONES

    var

        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';
        lblErrorRecurso: Label 'The indicated resource was not found', Comment = 'ESP=No se ha encontrado el recurso indicado';
        lblErrorReferencia: Label 'Reference %1 not found in the system', Comment = 'ESP=No se ha encontrado la referencia %1 en el sistema';
        lblErrorCodSeguimiento: Label 'No product tracking code has been indicated for reference %1', Comment = 'ESP=No se ha indicado código seguimiento producto para la referencia %1';
        lblErrorRecepcion: Label 'Warehouse receipt with number %1 not found', Comment = 'ESP=No se ha encontrado la recepción con número %1';
        lblErrorLineasCantidad: Label 'There are no pending lines with sufficient quantity', Comment = 'ESP=No hay lineas pendientes con cantidad suficiente';
        lblErrorAlRecepcionar: Label 'Warehouse receipt error', Comment = 'ESP=Error en la recepción';
        lblErrorPrefijoLote: Label 'Lot prefix not defined', comment = 'ESP=No se ha definido el prefijo del lote';
        lblErrorNSerieLote: Label 'A serial number has not been defined to generate the item lot no.', comment = 'ESP=No se ha definido un nº de serie para generar el lote de la referencia';
        lblErrorSinReferencia: Label 'Item No field is empty', comment = 'ESP=El campo referencia está vacio';
        lblErrorLoteInterno: Label 'Error generating internal Lot No number', comment = 'ESP=Error al generar el número de lote interno';
        lblErrorLote: Label 'Lot No not defined', comment = 'ESP=No se ha definido el lote';
        lblErrorLoteProveedor: Label 'Vendor Lot No not defined', comment = 'ESP=No se ha definido el lote de proveedor';
        lblErrorSerie: Label 'Serial No not defined', comment = 'ESP=No se ha definido el serie';
        lblErrorPaquete: Label 'Package No not defined', comment = 'ESP=No se ha definido el paquete';
        lblErrorPaqueteGenerico: Label 'Empty Package code not defined', comment = 'ESP=No se ha definido el código de paquete vacío';

        lblErrorLoteInternoNoExiste: Label 'Internal Lot No %1 was not found in the system', Comment = 'ESP=No se ha encontrado el lote interno %1 en el sistema';
        lblErrorSerieInternoNoExiste: Label 'Internal Serial No %1 was not found in the system', Comment = 'ESP=No se ha encontrado el serie interno %1 en el sistema';

        lblErrorLoteUnicoUbicacion: Label 'A Lot already exists at the destination bin', Comment = 'ESP=Ya existe otro lote en la ubicación de destino';

        lblErrorRegistrar: Label 'Error posting', Comment = 'ESP=Error al registrar';
        lblErrorAlmacen: Label 'App Warehouse not defined', comment = 'ESP=No se ha definido el almacén de la App';
        lblErrorTrackNo: Label 'Track No. Not Found', Comment = 'ESP=No se ha encontrado la trazabilidad';
        lblErrorSerialNoEmpty: Label 'Serial No. has not been indicated', Comment = 'ESP=El Nº de Serie no se ha indicado';
        lblErrorLotNoEmpty: Label 'Lot No. has not been indicated', Comment = 'ESP=El Nº de Lote no se ha indicado';
        lblErrorPackageNoEmpty: Label 'Package No. has not been indicated', Comment = 'ESP=El Nº de Paquete no se ha indicado';

        lblPaquete: Label 'Package', Comment = 'ESP=Paquete';
        lblLote: Label 'Lot No', Comment = 'ESP=Lote';
        lblSerie: Label 'Serial No', Comment = 'ESP=Serie';
        lblReferencia: Label 'Item No.', Comment = 'ESP=Referencia';
        lblErrorDiarioAlm: Label 'Journal Template Name not define on Location', comment = 'ESP=No se ha definido el diario en el almacén';

        lblErrorDiarioInv: Label 'Journal Template Name not define on Warehouse Setup', comment = 'ESP=No se ha definido el diario inventario en la configuración de almacén';
        lblErrorUbicacion: Label 'Bin %1 not found', Comment = 'ESP=Ubicación %1 no encontrada';
        lblErrorUbicacionAjuste: Label 'Adjust bin not defined', comment = 'ESP="Ubicación de ajuste no definida"';
        lblErrorSinInventario: Label 'Inventory not found', comment = 'ESP="No existe inventario"';
        lblErrorSinAlmacenamiento: Label 'Put-away not found', comment = 'ESP="Almacenamiento no encontrado"';
        lblErrorSinMovimiento: Label 'Movement not found', comment = 'ESP="Movimiento no encontrado"';

        lblErrorNadaQueRegistrar: Label 'Nothing to handle.', comment = 'ESP="Nada que registrar"';
        lblErrorMover: Label 'Error when moving', comment = 'ESP="Error al mover"';
        lblErrorSegProd: Label 'Product tracking definition error', comment = 'ESP="Error en la definición del seguimiento de producto"';
        lblErrorSerialDuplicado: Label 'The serial number already exists in the systemr', comment = 'ESP="El número de serie ya existe en el sistema"';
        lblErrorSerialDuplicadoEnvio: Label 'The serial number already exists in one shipment', comment = 'ESP="El número de serie ya existe en un envío"';
        lblErrorSinSeriePaquete: Label 'Package Serial No not define on Warehouse Setup', comment = 'ESP=No se ha definido el nº de serie del en la configuración de almacén';

        lblErrorEnvio: Label 'Shipment Not Found', Comment = 'ESP=No se ha encontrado en envío';
        lblErrorSinStock: Label 'Out of stock at bin ', Comment = 'ESP=No existe stock en la ubicación ';

}