codeunit 50100 WsApplication
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
    begin
        If not VJsonObjectLogin.ReadFrom(xJson) then
            EXIT(lblErrorJson);


        lPIN := DatoJsonTexto(VJsonObjectLogin, 'PIN');
        lLocation := DatoJsonTexto(VJsonObjectLogin, 'Location');

        Clear(RecRecursos);
        RecRecursos.SetRange(RecRecursos.Pin, lPIN);

        IF NOT RecRecursos.FindFirst() THEN
            exit(lblErrorRecurso);

        VJsonObjectRecurso.Add('No', RecRecursos."No.");
        VJsonObjectRecurso.Add('Name', RecRecursos.Name);
        VJsonObjectRecurso.Add('Copiar', FormatoBoolean(RecRecursos."Permite Copiar"));
        VJsonObjectRecurso.Add('Regularizar', FormatoBoolean(RecRecursos."Permite Regularizar"));
        VJsonObjectRecurso.Add('Inventario', FormatoBoolean(RecRecursos."Ver cantidad inventario"));

        RecWarehouseSetup.Get();
        VJsonObjectRecurso.Add('UsarPaquete', FormatoBoolean(RecWarehouseSetup."Usar paquetes"));
        VJsonObjectRecurso.Add('VerRecepcion', FormatoBoolean(RecWarehouseSetup."Ver Recepcion"));
        VJsonObjectRecurso.Add('VerSalidas', FormatoBoolean(RecWarehouseSetup."Ver Salidas"));
        VJsonObjectRecurso.Add('VerInventario', FormatoBoolean(RecWarehouseSetup."Ver Inventario"));
        VJsonObjectRecurso.Add('VerMovimientos', FormatoBoolean(RecWarehouseSetup."Ver Movimientos"));

        if (lLocation = '') then lLocation := App_Location();
        if (lLocation = '') then ERROR(lblErrorAlmacen);
        Clear(RecLocation);
        RecLocation.SetRange(RecLocation.Code, lLocation);
        if NOT RecLocation.FindFirst() then ERROR(lblErrorAlmacen);

        VJsonObjectRecurso.Add('Location', RecLocation.Code);
        VJsonObjectRecurso.Add('NombreAlamcen', RecLocation.Name);

        // Asier
        //IF (RecWarehouseSetup."Almacenamiento automatico") then
        //    VJsonObjectRecurso.Add('RequiereAlmacenamiento', FormatoBoolean(false))
        //ELSE
        VJsonObjectRecurso.Add('RequiereAlmacenamiento', FormatoBoolean(RecLocation."Require Put-away"));

        VJsonObjectRecurso.Add('RequierePicking', FormatoBoolean(RecLocation."Require Pick"));

        VJsonObjectRecurso.Add('ContRecepciones', FormatoNumero(Contador_Recepciones(lLocation)));
        VJsonObjectRecurso.Add('ContAlmacenamiento', FormatoNumero(Contador_Trabajos(lLocation, 1)));
        VJsonObjectRecurso.Add('ContPicking', FormatoNumero(Contador_Trabajos(lLocation, 1)));
        VJsonObjectRecurso.Add('ContInventario', FormatoNumero(Contador_Inventario(lLocation)));
        VJsonObjectRecurso.Add('ContTrabajos', FormatoNumero(Contador_Trabajos(lLocation, 0)));

        VJsonObjectRecurso.Add('ContEnvios', FormatoNumero(Contador_Envios(lLocation)));

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
    /// <param name="xTipo">0:Almacenamiento 1:Picking</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure Contador_Trabajos(xLocation: Text; xTipo: Integer): Integer
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        Contador: Integer;
    begin
        Contador := 0;
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        case xTipo of
            1:
                RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::"Put-away");
            2:
                RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        end;
        if RecWarehouseActivityHeader.findset then
            repeat
                Clear(RecWarehouseActivityLine);
                clear(RecWarehouseActivityLine);
                RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
                RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Qty. Outstanding", '>0');
                Contador += RecWarehouseActivityLine.Count();
            until RecWarehouseActivityHeader.Next() = 0;

        exit(Contador);
    end;

    local procedure Contador_Inventario(xLocation: Text): Integer
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecWarehouseJournalLine: Record "Warehouse Journal Line";
    begin
        RecWarehouseSetup.Get();

        Clear(RecWarehouseJournalLine);
        RecWarehouseJournalLine.SetRange("Location Code", xLocation);
        RecWarehouseJournalLine.SetRange("Journal Template Name", RecWarehouseSetup.AppInvJournalTemplateName);
        RecWarehouseJournalLine.SetRange("Journal Batch Name", RecWarehouseSetup.AppInvJournalBatchName);
        exit(RecWarehouseJournalLine.Count());
    end;




    #endregion

    #region WEB SERVICES


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
            Error(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN ERROR(lblErrorAlmacen);

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
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;

        VJsonText: Text;

        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        jTotalContenedores: Integer;
        jLoteProveedor: Text;
        jLotePreasignado: Text;

        BaseNumeroContenedor: Text;
        NumeracionInicial: Integer;
        i: Integer;
        NumContedor: Text;
        TextoContenedorFinal: Text;

        jImprimir: Boolean;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jTotalContenedores := DatoJsonInteger(VJsonObjectContenedor, 'Quantity');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        //Comprobaciones
        //Referencia
        Existe_Referencia(jReferencia, true);

        RecWarehouseSetup.Get();

        //Base para la creación del Nº Contenedor      
        if (RecWarehouseSetup."Usar Lote Proveedor") then
            BaseNumeroContenedor := jLoteProveedor
        else begin
            BaseNumeroContenedor := Base_Numero_Contenedor(1);

            //Si es un contenedor unitario se añade 00 si son varios 01,02....
            if jTotalContenedores = 1 then
                NumeracionInicial := 0
            else
                NumeracionInicial := 1;

            for i := 1 to jTotalContenedores do begin
                NumContedor := Format(NumeracionInicial);
                if (StrLen(NumContedor) = 1) then
                    NumContedor := '00' + NumContedor;
                if (StrLen(NumContedor) = 2) then
                    NumContedor := '0' + NumContedor;

                TextoContenedorFinal := BaseNumeroContenedor + NumContedor;

                //Si lleva un lote preasignado utilizamos ese
                if jLotePreasignado <> '' then begin
                    TextoContenedorFinal := jLotePreasignado;
                    jImprimir := false;
                end;

                Recepcionar_Contenedor(VJsonObjectContenedor, TextoContenedorFinal, NOT jImprimir);

                NumeracionInicial += 1;

            end;


        end;


        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);
        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsEliminarContenedor(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Contenedor_Recepcion(xJson);

        Actualizar_Cantidad_Recibir(jRecepcion);
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
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLinea := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        Registrar_Recepcion(jRecepcion, jLinea);

        Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsContenidoUbicacion(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jLocation: Text;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jItemNo := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectContenedor, 'Bin');
        jZone := DatoJsonTexto(VJsonObjectContenedor, 'Zone');
        jLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');


        EXIT(Contenidos_Ubicacion(jItemNo, jZone, jBin, jLocation));


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
            Error(lblErrorJson);

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
            Error(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Lineas_Almacenamiento(lNo, lLocation);

        exit(VJsonText);

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
            Error(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Movimientos_Almacen(lNo, lLocation);

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
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jBinTo := DatoJsonTexto(VJsonObjectDatos, 'BinTo');

        jNo := DatoJsonTexto(VJsonObjectDatos, 'No');

        exit(Registrar_Almacenamiento(jNo, jLotNo, jItemNo, jBinTo));



    end;




    procedure WsInventarioTrazabilidad(xJson: Text): Text
    var

        lTrackNo: Text;
        lTipo: Code[1];

        RecWarehouseSetup: record "Warehouse Setup";
        QueryLotInventory: Query "Lot Numbers by Bin";
        RecItem: Record Item;
        VJsonObjectDatos: JsonObject;

        VJsonObjectTrazabilidad: JsonObject;

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        Cantidad: Decimal;
        Iventario: Decimal;
        VJsonText: Text;

        Encontrado: Boolean;

        Primero: Boolean;
        lLocation: Text;
        vPaquete: Text;
        vSerie: Text;

        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            Error(lblErrorJson);

        lTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        lTipo := Tipo_Trazabilidad(lTrackNo);

        if (lTipo = 'N') THEN ERROR(lblErrorTrackNo);

        VJsonObjectTrazabilidad.Add('TrackNo', lTrackNo);

        Clear(QueryLotInventory);
        case lTipo of
            'L':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Lot_No, lTrackNo);
                end;
            'S':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Serial_No, lTrackNo);
                end;
            'P':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Package_No, lTrackNo);
                end;

            else
        end;

        QueryLotInventory.Open();
        //Inventario por ubicación

        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, lLocation);

        Primero := true;
        Cantidad := 0;
        QueryLotInventory.Open();
        WHILE QueryLotInventory.READ DO BEGIN
            if (Primero) then begin
                IF (lTipo = 'P') THEN begin
                    VJsonObjectTrazabilidad.Add('Tipo', lblPaquete);
                    VJsonObjectTrazabilidad.Add('ItemNo', '');
                    VJsonObjectTrazabilidad.Add('Description', '');
                end;
                if (lTipo = 'L') THEN begin
                    VJsonObjectTrazabilidad.Add('Tipo', lblLote);
                    VJsonObjectTrazabilidad.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectTrazabilidad.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                end;
                if (lTipo = 'S') THEN begin
                    VJsonObjectTrazabilidad.Add('Tipo', lblSerie);
                    VJsonObjectTrazabilidad.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectTrazabilidad.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                end;
                Primero := false;
            end;

            VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
            VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);
            VJsonObjectInventario.Add('PackageNo', QueryLotInventory.Package_No);
            VJsonObjectInventario.Add('Zone', QueryLotInventory.Zone_Code);
            VJsonObjectInventario.Add('Bin', QueryLotInventory.Bin_Code);
            VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty_Base));

            VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
            Clear(VJsonObjectInventario);

        END;

        VJsonObjectTrazabilidad.Add('Bins', VJsonArrayInventario.Clone());

        VJsonObjectTrazabilidad.WriteTo(VJsonText);
        exit(VJsonText);

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
            Error(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN ERROR(lblErrorAlmacen);

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
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jZone := DatoJsonTexto(VJsonObjectDatos, 'Zone');

        exit(Inventario_Recurso(jRecurso, jLocation, jZone, jBin, jItemNo));

    end;


    procedure WsAgregarLineaInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jBinInv: Text;
        jQuantity: Decimal;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');

        jTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        jBinInv := DatoJsonTexto(VJsonObjectDatos, 'BinInv');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Real');

        Validar_Linea_Inventario(jTrackNo, jBinInv, jQuantity);

        exit(Inventario_Recurso(jRecurso, jLocation, jZone, jBin, jItemNo));

    end;



    procedure WsMover(xJson: Text): Text
    var

        VJsonObjectDatos: JsonObject;

        lContenedor: Text;
        lAlmacen: Boolean;

        lUbicadionDesde: Text;
        lUbicacionHasta: Text;
        lCantidad: Decimal;
        lResource: Text;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            Error('Respuesta no valida. Se esperaba un Json');

        lContenedor := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lUbicadionDesde := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');
        lUbicacionHasta := DatoJsonTexto(VJsonObjectDatos, 'BinTo');
        lCantidad := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');
        lResource := DatoJsonTexto(VJsonObjectDatos, 'Resource');
        lAlmacen := DatoJsonBoolean(VJsonObjectDatos, 'Location');

        AppCreateReclassWarehouse(lUbicadionDesde, lUbicacionHasta, lCantidad, lContenedor, lResource);

        exit('OK');

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

    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        //RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        if RecWarehouseActivityHeader.findset then begin

            VJsonObjectPicking.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectPicking.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));
            VJsonObjectPicking.Add('Type', Format(RecWarehouseActivityHeader.Type));

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
                        VJsonObjectLineas.Add('Type', Format(RecWarehouseActivityLine."Activity Type"));
                        VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                        VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));
                        VJsonObjectLineas.Add('BinFrom', RecWarehouseActivityLine."Bin Code");
                        VJsonObjectLineas.Add('BinTo', lUbicacionEnvio);
                        VJsonObjectLineas.Add('LotNo', RecWarehouseActivityLine."Lot No.");
                        VJsonObjectLineas.Add('SerialNo', RecWarehouseActivityLine."Serial No.");
                        VJsonObjectLineas.Add('PackageNo', RecWarehouseActivityLine."Package No.");
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





    procedure Crear_Movimientos_Almacenamiento()
    var

    begin



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
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        CR: Char;

    begin

        CR := 13;

        clear(RecWhsReceiptHeader);
        RecWhsReceiptHeader.SetRange("No.", xNo);
        if RecWhsReceiptHeader.FindFirst() then;

        Actualizar_Cantidad_Recibir(RecWhsReceiptHeader."No.");

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
                VJsonObjectLines.Add('LineNo', RecWhsReceiptLine."Line No.");
                VJsonObjectLines.Add('ProdOrderNo', '');
                VJsonObjectLines.Add('Reference', RecWhsReceiptLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsReceiptLine.Description);

                Clear(RecItem);
                RecItem.Get(RecWhsReceiptLine."Item No.");
                VJsonObjectLines.Add('Caducidad', FormatoBoolean(RecItem."Usar Caducidad"));

                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsReceiptLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsReceiptLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToReceive', RecWhsReceiptLine."Qty. to Receive (Base)");// ."Qty. to Receive");

                if (RecWhsReceiptLine."Qty. to Receive (Base)" < RecWhsReceiptLine."Qty. Outstanding (Base)") then
                    VJsonObjectLines.Add('Complete', false)
                else
                    VJsonObjectLines.Add('Complete', true);

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
                VJsonArrayReservas := Reservas(RecWhsReceiptLine);
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

    local procedure Reservas(RecWhseReceiptLine: Record "Warehouse Receipt Line"): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
        RecReservationEntry.SETRANGE("Source ID", RecWhseReceiptLine."Source No.");
        RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseReceiptLine."Source Line No.");
        RecReservationEntry.SETRANGE("Item No.", RecWhseReceiptLine."Item No.");
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('Quantity', FormatoNumero(RecReservationEntry."Quantity (Base)"));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;

    local procedure Actualizar_Cantidad_Recibir(xRecepcion: Text)
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
    end;


    local procedure Recepcionar_Contenedor(VJsonObjectContenedor: JsonObject; xContenedor: Text; xOmitirImpresion: Boolean)
    var
        RecItem: Record Item;
        RecLote: Record "Lot No. Information";
        RecWhseReceiptHeader: Record "Warehouse Receipt Header";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecReservationEntry: Record "Reservation Entry";
        RecWhseSetup: Record "Warehouse Setup";
        RecResource: Record Resource;
        RecPurchaseHeader: Record "Purchase Header";
        RecPurchaseLine: Record "Purchase Line";

        vNumReserva: Integer;

        jAlbaran: Text;
        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        jTotalContenedores: Integer;
        jLoteProveedor: Text;
        jLotePreasignado: Text;
        jImprimir: Boolean;
        jEnAlerta: Boolean;
        jText: Text;
        jFoto: Text;
        jRecurso: Text;

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
        jTotalContenedores := DatoJsonInteger(VJsonObjectContenedor, 'Quantity');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');


        jEnAlerta := DatoJsonBoolean(VJsonObjectContenedor, 'OnAlert');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        if (jRecurso = '') then ERROR(lblErrorRecurso);

        //Comprobaciones
        //Referencia
        Existe_Referencia(jReferencia, true);

        //Añadir ficha Lote
        Clear(RecLote);
        RecLote.SetRange("Lot No.", xContenedor);
        if NOT RecLote.FindFirst() then BEGIN

            RecLote.init;

            RecLote."Item No." := jReferencia;
            RecLote."Lot No." := xContenedor;
            RecLote.Description := RecItem.Description;
            RecLote.CantidadInicial := jUnidades;
            RecLote."Fecha Recepcion" := TODAY();
            RecLote."Albaran Proveedor" := jAlbaran;
            if (jLoteProveedor <> '') then
                RecLote."Lote Proveedor" := jLoteProveedor
            else
                RecLote."Lote Proveedor" := jAlbaran;

            RecLote.INSERT;

        END;

        IF jEnAlerta THEN BEGIN
            jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
            jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
            If (jFoto <> '') THEN BEGIN

                NombreFoto := 'A-' + xContenedor + '.jpg';

                cuTempBlob.CreateOutStream(oStream);
                cuBase64.FromBase64(jFoto, oStream);

                cuTempBlob.CreateInStream(iStream);
                Clear(RecLote.Foto);
                RecLote.Foto.ImportStream(iStream, NombreFoto);

                RecLote.Alerta := jText;

            END;
            RecLote.Modify();
        END;

        //Añadir Nº Albarán a la cabecera de la recepción
        clear(RecWhseReceiptHeader);
        RecWhseReceiptHeader.SetRange("No.", jRecepcion);
        if not RecWhseReceiptHeader.FindFirst() then Error(StrSubstNo(lblErrorRecepcion, jRecepcion));

        RecWhseReceiptHeader."Vendor Shipment No." := jAlbaran;
        RecWhseReceiptHeader.Modify();

        //Poner cantidad a recibir a 0 en todos los movimientos
        Vaciar_Cantidad_Recibir(jRecepcion);

        //Actualizar la cantidad a recibir con los movimientos de reserva
        Actualizar_Cantidad_Recibir(jRecepcion);

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

            clear(RecWhseReceiptLine);
            RecWhseReceiptLine.RESET();
            RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
            RecWhseReceiptLine.SETRANGE("Item No.", jReferencia);
            RecWhseReceiptLine.SETRANGE("Line No.", vLinea);
            if not RecWhseReceiptLine.FindFirst() then Error(lblErrorAlRecepcionar);

            CLEAR(RecPurchaseHeader);
            RecPurchaseHeader.SetRange("No.", RecWhseReceiptLine."Source No.");
            IF RecPurchaseHeader.FindFirst() THEN begin
                RecLote.Proveedor := RecPurchaseHeader."Buy-from Vendor No.";
                RecLote.Modify();
            end;

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
            RecReservationEntry.validate("Item No.", jReferencia);
            RecReservationEntry."Location Code" := RecWhseReceiptLine."Location Code";
            RecReservationEntry."Quantity (Base)" := jUnidades;
            RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
            RecReservationEntry."Creation Date" := WORKDATE;
            RecReservationEntry."Source Type" := 39;
            RecReservationEntry."Source Subtype" := 1;
            RecReservationEntry."Source ID" := RecWhseReceiptLine."Source No.";
            RecReservationEntry."Source Ref. No." := RecWhseReceiptLine."Source Line No.";
            RecReservationEntry."Expected Receipt Date" := WORKDATE;
            RecReservationEntry."Created By" := USERID;
            RecReservationEntry."Qty. per Unit of Measure" := RecWhseReceiptLine."Qty. per Unit of Measure";
            RecReservationEntry.Quantity := jUnidades;
            RecReservationEntry."Qty. to Handle (Base)" := jUnidades;
            RecReservationEntry."Qty. to Invoice (Base)" := jUnidades;
            RecReservationEntry."Lot No." := xContenedor;
            RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
            RecReservationEntry.INSERT;
        end;

        //Poner cantidad a recibir a 0 en todos los movimientos
        Vaciar_Cantidad_Recibir(jRecepcion);

        //Actualizar la cantidad a recibir con los movimientos de reserva
        Actualizar_Cantidad_Recibir(jRecepcion);

        //Imprimir etiqueta
        Clear(RecResource);
        RecResource.SetRange("No.", jRecurso);
        IF NOT RecResource.FindFirst() then ERROR(lblErrorRecurso);

        /*if jImprimir and not xOmitirImpresion then
            Imprimir_Componente(RecResource."Printer Name", 1, lReferencia, xContenedor);*/

    end;

    local procedure Vaciar_Cantidad_Recibir(xRecepcion: Text)
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

    end;

    local procedure Eliminar_Contenedor_Recepcion(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLoteInterno: Text;
        EsSubcontratacion: Boolean;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);


        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLoteInterno := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');

        CLEAR(RecReservationEntry);
        //RecReservationEntry.SetRange("Source ID", lRecepcion);
        RecReservationEntry.SetRange("Lot No.", jLoteInterno);
        IF NOT RecReservationEntry.FindFirst() THEN ERROR(lblErrorLoteInternoNoExiste);

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


    local procedure Registrar_Recepcion(xRecepcion: Text; xLinea: Integer)
    var
        pgWR: Page "Warehouse Receipt";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        cuWhsePostReceipt: Codeunit "Whse.-Post Receipt";
        RecWarehouseSetup: Record "Warehouse Setup";
    begin
        RecWhseReceiptLine.RESET;
        RecWhseReceiptLine.SETRANGE("No.", xRecepcion);

        if (xLinea > 0) then
            RecWhseReceiptLine.SETRANGE(RecWhseReceiptLine."Line No.", xLinea);

        IF RecWhseReceiptLine.FindSet() THEN BEGIN

            if not cuWhsePostReceipt.RUN(RecWhseReceiptLine) then
                ERROR(lblErrorRegistrar);



            // Asier
            //RecWarehouseSetup.Get();
            //if RecWarehouseSetup."Almacenamiento automatico" then
            //    Registrar_Almacenamiento(xRecepcion);


        END ELSE
            Error(lblErrorRegistrar);


    end;



    procedure Registrar_Almacenamiento(xRecepcion: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecRecepRegistradas: Record "Posted Whse. Receipt Header";

        ZonaRecepcionados: Code[20];
        UbicacionRecepcionados: Code[20];

        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";
        RecBin: Record Bin;
        VJsonObjectDatos: JsonObject;

        lResource: Text;

    begin

        Clear(RecRecepRegistradas);
        RecRecepRegistradas.SetRange(RecRecepRegistradas."Whse. Receipt No.", xRecepcion);
        if NOT RecRecepRegistradas.FindLast() then ERROR('No se ha registrado correctamente la recepción %1', xRecepcion);

        //Asier
        //RecWarehouseSetup.Get();
        //if RecWarehouseSetup."Ubicacion Recepcionados" = '' then ERROR('No se ha definido ubicación de recepcionados');
        //if RecWarehouseSetup."Zona Recepcionados" = '' then ERROR('No se ha definido zona de recepcionados');

        //UbicacionRecepcionados := RecWarehouseSetup."Ubicacion Recepcionados";
        //ZonaRecepcionados := RecWarehouseSetup."Zona Recepcionados";

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

    #region INFORMACION

    procedure Contenidos_Ubicacion(xItemNo: Text; xZone: Text; xBin: Text; xLocation: Text): Text
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
    begin

        Clear(RecBinContent);
        RecBinContent.SetRange("Location Code", xLocation);

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
                VJsonObjectContenido.Add('BinInventory', FormatoNumero(RecBinContent.Quantity));

                //Inventario por ubicación
                Clear(QueryLotInventory);
                QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', RecBinContent."Item No.");
                QueryLotInventory.SetFilter(QueryLotInventory.Bin_Code, '=%1', RecBinContent."Bin Code");
                QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty_Base, '>0');

                QueryLotInventory.Open();
                WHILE QueryLotInventory.READ DO BEGIN
                    VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
                    VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);
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

        end;

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

        exit('N');


    end;


    procedure AppCreateReclassWarehouse(xFromBin: code[20]; xToBin: code[20]; xQty: decimal; xTrackNo: code[20]; xResourceNo: code[20]);
    var
        RecWarehouseSetup: record "Warehouse Setup";
        WhseJnlTemplate: record "Warehouse Journal Template";
        WhseJnlLine: record "Warehouse Journal Line";
        WhseJnlLineLast: record "Warehouse Journal Line";
        RecBin: Record Bin;

        WhseItemTrackingLine: record "Whse. Item Tracking Line";
        WhseItemTrackingLineLast: record "Whse. Item Tracking Line";
        LineNo: Integer;

        sTipo: Text;


        WhseJnlRegisterLine: codeunit "Whse. Jnl.-Register Line";

        lblErrorReclasif: Label 'Not exist Reclassification Template', comment = 'ESP="No existe Libro diario Reclasificación"';
    begin


        RecWarehouseSetup.get;
        WhseJnlTemplate.reset;
        WhseJnlTemplate.setrange(Type, WhseJnlTemplate.Type::Reclassification);
        if not WhseJnlTemplate.findset then
            error(lblErrorReclasif);

        WhseJnlLine.RESET;
        WhseJnlLine.SETRANGE("Journal Template Name", RecWarehouseSetup.AppJournalTemplateName);
        WhseJnlLine.SETRANGE("Journal Batch Name", RecWarehouseSetup.AppJournalBatchName);
        IF WhseJnlLine.findset then
            repeat
                WhseJnlLine.delete;
            until WhseJnlLine.Next = 0;

        Clear(RecBin);
        RecBin.SetRange(Code, xFromBin);
        IF NOT RecBin.FindFirst() THEN Error(lblErrorUbicacion);

        LineNo := 10001;
        WhseJnlLineLast.Reset;
        WhseJnlLineLast.setrange("Journal Template Name", RecWarehouseSetup.AppJournalTemplateName);
        WhseJnlLineLast.setrange("Journal Batch Name", RecWarehouseSetup.AppJournalBatchName);
        WhseJnlLineLast.setrange("Location Code", RecBin."Location Code");
        if WhseJnlLineLast.findlast then
            LineNo := WhseJnlLineLast."Line No." + 10000;

        WhseJnlLine.init;
        WhseJnlLine."Journal Template Name" := RecWarehouseSetup.AppJournalTemplateName;
        WhseJnlLine."Journal Batch Name" := RecWarehouseSetup.AppJournalBatchName;
        WhseJnlLine.validate("Location Code", RecBin."Location Code");
        WhseJnlLine."Line No." := LineNo;
        WhseJnlLine.validate("Registering Date", workdate);
        WhseJnlLine.insert;
        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
        WhseJnlLine."Source Code" := 'DIARECLALM';
        WhseJnlLine.validate("Item No.", Item_Tipo_Dato(xTrackNo));
        WhseJnlLine.validate("From Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("From Bin Code", xFromBin);

        Clear(RecBin);
        RecBin.SetRange(Code, xToBin);
        IF NOT RecBin.FindFirst() THEN Error(lblErrorUbicacion);


        WhseJnlLine.validate("To Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("To Bin Code", xToBin);
        WhseJnlLine.validate(Quantity, xQty);
        WhseJnlLine."Whse. Document No." := 'MOVE';
        //WhseJnlLine.Resource := Resource;

        WhseJnlLine.modify;

        if WhseItemTrackingLineLast.findlast then;
        WhseItemTrackingLine.init;
        WhseItemTrackingLine."Entry No." := WhseItemTrackingLineLast."Entry No." + 1;
        WhseItemTrackingLine."Item No." := WhseJnlLine."Item No.";// xItemNo;
        WhseItemTrackingLine."Location Code" := RecBin."Location Code";
        WhseItemTrackingLine."Quantity (Base)" := xQty;
        WhseItemTrackingLine."Source Type" := 7311;
        WhseItemTrackingLine."Source ID" := RecWarehouseSetup.AppJournalBatchName;
        WhseItemTrackingLine."Source Batch Name" := RecWarehouseSetup.AppJournalTemplateName;
        WhseItemTrackingLine."Source Ref. No." := LineNo;
        WhseItemTrackingLine."Qty. per Unit of Measure" := 1;
        WhseItemTrackingLine."Qty. to Handle (Base)" := xQty;
        WhseItemTrackingLine."Qty. to Handle" := xQty; //"Qty. per Unit of Measure"

        sTipo := Tipo_Dato(xTrackNo);

        case sTipo of
            'L':
                begin
                    WhseItemTrackingLine."New Lot No." := xTrackNo;
                    WhseItemTrackingLine."Lot No." := xTrackNo;
                end;
            'S':
                begin
                    WhseItemTrackingLine."Serial No." := xTrackNo;
                    WhseItemTrackingLine."New Serial No." := xTrackNo;
                end;
            'P':
                begin
                    WhseItemTrackingLine."Package No." := xTrackNo;
                    WhseItemTrackingLine."Package No." := xTrackNo;
                end;
            'N':
                Error(lblErrorTrackNo);
        end;

        WhseItemTrackingLine.insert;

        WhseJnlLine.reset;
        WhseJnlLine.SETRANGE("Whse. Document No.", 'MOVE');
        WhseJnlLine.SETRANGE("To Bin Code", '=%1', xToBin);
        IF WhseJnlLine.FindSet() then begin
            //Registrar
            CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch", WhseJnlLine)
        end ELSE
            Error(lblErrorMover);

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

    local procedure Registrar_Almacenamiento(xNo: Text; xLotNo: Text; xItemNo: Text; jBinTo: Text): Text
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";

        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        RecWarehouseActivityLine.SetFilter("Qty. to Handle", '>0');
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Bin Code", jBinTo);
            RecWarehouseActivityLine.Modify();
        end;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        RecWarehouseActivityLine.SetFilter("Qty. to Handle", '>0');
        //RecWarehouseActivityLine.SetFilter("Line No.", '=%1|%2', lLineNoFrom, lLineNoTo);
        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine)
        ELSE
            Error(lblErrorSinAlmacenamiento);

        VJsonObjectAlmacenamiento := Objeto_Almacenamiento(xNo);
        VJsonObjectAlmacenamiento.WriteTo(VJsonText);
        exit(VJsonText);

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

        clear(RecWhsShipmentHeader);
        RecWhsShipmentHeader.SetRange("No.", xNo);
        if RecWhsShipmentHeader.FindFirst() then;

        Actualizar_Cantidad_Enviar(RecWhsShipmentHeader."No.");

        Clear(VJsonObjectShipments);

        VJsonObjectShipments.Add('No', RecWhsShipmentHeader."No.");
        VJsonObjectShipments.Add('Date', FormatoFecha(RecWhsShipmentHeader."Posting Date"));
        VJsonObjectShipments.Add('CustomerName', '');

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
                VJsonObjectLines.Add('LineNo', RecWhsShipmentLine."Line No.");
                VJsonObjectLines.Add('ProdOrderNo', '');
                VJsonObjectLines.Add('Reference', RecWhsShipmentLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsShipmentLine.Description);

                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsShipmentLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsShipmentLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToReceive', RecWhsShipmentLine."Qty. to Ship (Base)");// ."Qty. to Receive");

                if (RecWhsShipmentLine."Qty. to Ship (Base)" < RecWhsShipmentLine."Qty. Outstanding (Base)") then
                    VJsonObjectLines.Add('Complete', false)
                else
                    VJsonObjectLines.Add('Complete', true);

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
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('Quantity', FormatoNumero(-RecReservationEntry."Quantity (Base)"));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;

    #endregion

    #region INVENTARIO


    procedure Inventario_Recurso(xResourceNo: Text; xLocation: Text; xZone: Text; xBin: Text; xItemNo: Text): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;
    begin

        if (xResourceNo = '') then ERROR(lblErrorRecurso);

        RecWarehouseSetup.get();

        if ((RecWarehouseSetup.AppInvJournalTemplateName = '') or (RecWarehouseSetup.AppInvJournalBatchName = '')) then
            ERROR(lblErrorDiarioInv);

        Clear(RecRecurso);
        RecRecurso.SetRange("No.", xResourceNo);
        if not RecRecurso.FindFirst() THEN ERROR(lblErrorRecurso);

        //Todo lo que no sea urgencia
        Clear(RecWarehouseJournalLine);
        RecWarehouseJournalLine.SetRange("Location Code", xLocation);
        RecWarehouseJournalLine.SetRange("Journal Template Name", RecWarehouseSetup.AppInvJournalTemplateName);
        RecWarehouseJournalLine.SetRange("Journal Batch Name", RecWarehouseSetup.AppInvJournalBatchName);

        if (xZone <> '') then
            RecWarehouseJournalLine.SetRange("Zone Code", xZone);
        if (xBin <> '') then
            RecWarehouseJournalLine.SetRange("Bin Code", xBin);
        if (xItemNo <> '') then
            RecWarehouseJournalLine.SetRange("Item No.", xItemNo);

        //RecWarehouseJournalLine.SetRange(Urgente, false);
        //if (RecRecurso."Ver Todo" = false) then
        //    RecWarehouseJournalLine.SetFilter(Asignado, '=%1|%2', xRecurso, '');

        if RecWarehouseJournalLine.findset then begin
            repeat
                VJsonObjectInventario.Add('Location', RecWarehouseJournalLine."Location Code");
                VJsonObjectInventario.Add('LineNo', FormatoNumero(RecWarehouseJournalLine."Line No."));
                VJsonObjectInventario.Add('ItemNo', RecWarehouseJournalLine."Item No.");
                VJsonObjectInventario.Add('Description', RecWarehouseJournalLine.Description);
                VJsonObjectInventario.Add('Zone', RecWarehouseJournalLine."Zone Code");
                VJsonObjectInventario.Add('Bin', RecWarehouseJournalLine."Bin Code");
                VJsonObjectInventario.Add('LotNo', RecWarehouseJournalLine."Lot No.");
                VJsonObjectInventario.Add('SerialNo', RecWarehouseJournalLine."Serial No.");
                VJsonObjectInventario.Add('PackagelNo', RecWarehouseJournalLine."Package No.");

                VJsonObjectInventario.Add('Date', FormatoFecha(RecWarehouseJournalLine."Registering Date"));
                VJsonObjectInventario.Add('Calculada', FormatoNumero(RecWarehouseJournalLine."Qty. (Calculated)"));
                VJsonObjectInventario.Add('Real', FormatoNumero(RecWarehouseJournalLine."Qty. (Phys. Inventory)"));
                VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecWarehouseJournalLine.Quantity));
                VJsonObjectInventario.Add('Unit', RecWarehouseJournalLine."Unit of Measure Code");

                VJsonObjectInventario.Add('Leido', FormatoBoolean(RecWarehouseJournalLine.Leido));

                //VJsonObjectInventario.Add('Resource', RecWarehouseJournalLine.Asignado);
                //VJsonObjectInventario.Add('Revisado', FormatoBoolean(RecWarehouseJournalLine.Revisado));
                //VJsonObjectInventario.Add('Urgente', FormatoBoolean(RecWarehouseJournalLine.Urgente));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            until RecWarehouseJournalLine.Next() = 0;

        end;

        VJsonArrayInventario.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    procedure Validar_Linea_Inventario(xTrackNo: Text; xBin: Text; xQuantity: Decimal): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecWarehouseJournalLineAux: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecWarehouseSetup: Record "Warehouse Setup";
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
                Error(lblErrorTrackNo);
        end;

        RecWarehouseJournalLine.SetRange("Bin Code", xBin);

        IF (RecWarehouseJournalLine.FindFirst()) THEN begin

            RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory)", xQuantity);
            RecWarehouseJournalLine.Leido := true;
            RecWarehouseJournalLine.Modify();
        end else begin

            Agregar_Linea_Inventario(xTrackNo, xBin, xQuantity, sTipo);


        end;

    end;


    procedure Agregar_Linea_Inventario(xTrackNo: Text; xBin: Text; xQuantity: Decimal; xTipo: Code[1]): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecWarehouseJournalLineAux: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecWarehouseSetup: Record "Warehouse Setup";
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
    begin


        RecWarehouseSetup.GET();
        IF (RecWarehouseSetup.AppInvJournalTemplateName = '') THEN ERROR(lblErrorDiarioInv);
        IF (RecWarehouseSetup.AppInvJournalBatchName = '') THEN ERROR(lblErrorDiarioInv);

        clear(RecWarehouseJournalLineAux);
        RecWarehouseJournalLineAux.SETRANGE("Journal Template Name", RecWarehouseSetup.AppInvJournalTemplateName);
        RecWarehouseJournalLineAux.SETRANGE("Journal Batch Name", RecWarehouseSetup.AppInvJournalBatchName);
        if RecWarehouseJournalLineAux.FindLast() then
            NumeroLinea := RecWarehouseJournalLineAux."Line No." + 1001
        else
            Error(lblErrorSinInventario);
        ;

        //Se añade la línea nueva
        Clear(RecBin);
        RecBin.SetRange(code, xBin);
        IF NOT RecBin.FindFirst() then Error(StrSubstNo(lblErrorUbicacion, xBin));

        RecWarehouseJournalLine.Init();
        RecWarehouseJournalLine."Journal Template Name" := RecWarehouseSetup.AppInvJournalTemplateName;
        RecWarehouseJournalLine."Journal Batch Name" := RecWarehouseSetup.AppInvJournalBatchName;
        NumeroLinea += 1000;
        RecWarehouseJournalLine."Line No." := NumeroLinea;
        RecWarehouseJournalLine."Registering Date" := Today;
        RecWarehouseJournalLine."Location Code" := RecBin."Location Code";
        RecWarehouseJournalLine."Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine.Validate("Bin Code", xBin);
        RecWarehouseJournalLine.Validate("Item No.", Item_Tipo_Dato(xTrackNo));

        if (xTipo = '') then xTipo := Tipo_Dato(xTrackNo);

        case xTipo of
            'L':
                RecWarehouseJournalLine."Lot No." := xTrackNo;
            'S':
                RecWarehouseJournalLine."Serial No." := xTrackNo;
            'P':
                RecWarehouseJournalLine."Package No." := xTrackNo;
            'N':
                Error(lblErrorTrackNo);
        end;



        RecWarehouseJournalLine."To Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine."To Bin Code" := RecBin.Code;

        Clear(RecLocation);
        RecLocation.Get(RecBin."Location Code");
        Clear(RecBin);
        RecBin.SetRange(code, RecLocation."Adjustment Bin Code");
        IF NOT RecBin.FindFirst() then Error(lblErrorUbicacionAjuste);

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


    #region FUNCIONES BC

    /// <summary>
    /// Determina si es un Lote(L), Un Serie(S),Paquete(P), Nulo(N)
    /// </summary>
    local procedure Tipo_Dato(xTrackNo: Text): Code[1]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
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
        RecItemReference.SetRange("Item No.", xItem);
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

    local procedure Descripcion_ItemNo(xItem: Code[50]): Text
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
    procedure Base_Numero_Contenedor(xTipo: Integer): Text
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecLotNoInf: Record "Lot No. Information";
        cuNoSeriesManagement: Codeunit NoSeriesManagement;
        TxtContenedor: Text;
        xInicial: Text;
        Formato: Text;
        xNumero: Integer;
        sufijo: Text;
        SufijoNumSerie: Text;
    begin

        RecWarehouseSetup.get();

        TxtContenedor := '';

        /* ASIER
        if NOT RecWarehouseSetup."Usar serie para Lote" THEN BEGIN

            case xTipo of
                1:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Materia Prima";
                    end;
                2:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Semielaborado";
                    end;
                3:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Producto Terminado";
                    end;
            end;

            if (xInicial = '') then Error(lblErrorPrefijoLote);

            if (RecWarehouseSetup."Lot No Serial" = '') then Error(lblErrorNSerieLote);

            Formato := '<year,2><month,2><day,2><Hours24,2>';
            sufijo := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Lot No Serial", WorkDate, true);
            TxtContenedor := xInicial + Format(CurrentDateTime, 8, Formato) + sufijo;
        END ELSE begin
            TxtContenedor := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Lot No Serial", WorkDate, true);
        end;
        */
        Clear(RecLotNoInf);
        RecLotNoInf.SetRange("Lot No.", TxtContenedor);
        if RecLotNoInf.FindFirst() then ERROR(lblErrorLoteInterno);


        exit(TxtContenedor);
    end;


    local procedure App_Location(): Code[50]
    var
        RecWarehouseSetup: Record "Warehouse Setup";
    begin
        RecWarehouseSetup.GET();
        if (RecWarehouseSetup."App Location" = '') then Error(lblErrorAlmacen);

        exit(RecWarehouseSetup."App Location");
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
        lblErrorNSerieLote: Label 'A serial number has not been defined to generate the batch', comment = 'ESP=No se ha definido un nº de serie para generar el lote';
        lblErrorLoteInterno: Label 'Error generating internal Lot No number', comment = 'ESP=Error al generar el número de lote interno';

        lblErrorLoteInternoNoExiste: Label 'Internal Lot No %1 was not found in the system', Comment = 'ESP=No se ha encontrado el lote interno %1 en el sistema';
        lblErrorRegistrar: Label 'Error posting', Comment = 'ESP=Error al registrar';
        lblErrorAlmacen: Label 'App Warehouse not defined', comment = 'ESP=No se ha definido el almacén de la App';
        lblErrorTrackNo: Label 'Track No. Not Found', Comment = 'ESP=No se ha encontrado la trazabilidad';
        lblPaquete: Label 'Package', Comment = 'ESP=Paquete';
        lblLote: Label 'Lot No', Comment = 'ESP=Lote';
        lblSerie: Label 'Serial No', Comment = 'ESP=Serie';
        lblErrorDiarioInv: Label 'Journal Template Name not define on Warehouse Setup', comment = 'ESP=No se ha definido el diario inventario en la configuración de almacén';
        lblErrorUbicacion: Label 'Bin %1 not found', Comment = 'ESP=Ubicación %1 no encontrada';
        lblErrorUbicacionAjuste: Label 'Adjust bin not defined', comment = 'ESP="Ubicación de ajuste no definida"';
        lblErrorSinInventario: Label 'Inventory not found', comment = 'ESP="No existe inventario"';
        lblErrorSinAlmacenamiento: Label 'Put-away not found', comment = 'ESP="Almacenamiento no encontrado"';
        lblErrorNadaQueRegistrar: Label 'Nothing to handle.', comment = 'ESP="Nada que registrar"';
        lblErrorMover: Label 'Error when moving', comment = 'ESP="Error al mover"';

}