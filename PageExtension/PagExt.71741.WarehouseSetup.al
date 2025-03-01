pageextension 71741 "Warehouse Setup" extends "Warehouse Setup"
{
    layout
    {
        addlast(content)
        {
            group(App)
            {
                Caption = 'Aplicación SGA';

                /*field("App Location"; Rec."App Location")
                {
                    ApplicationArea = all;
                }*/

                field("Numero Serie Inventario"; Rec."Numero Serie Inventario")
                {
                    ApplicationArea = all;
                }
                group(AppActivar)
                {
                    Caption = 'Activar';

                    field("Ver Recepcion"; Rec."Ver Recepcion")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Subcontratacion"; Rec."Ver Subcontratacion")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Salidas"; Rec."Ver Salidas")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Inventario"; Rec."Ver Inventario")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Movimientos"; Rec."Ver Movimientos")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Picking Fab"; Rec."Ver Picking Fab")
                    {
                        ApplicationArea = all;
                    }
                    field("Ver Altas"; Rec."Ver Altas")
                    {
                        ApplicationArea = all;
                    }

                    /*field("Usar paquetes"; Rec."Usar paquetes")
                    {
                        ApplicationArea = all;
                    }*/
                    field("Numero Serie Paquete"; Rec."Numero Serie Paquete")
                    {
                        ApplicationArea = all;
                    }
                    field("Codigo Sin Paquete"; Rec."Codigo Sin Paquete")
                    {
                        ApplicationArea = all;
                    }
                }
                group(AppLote)
                {
                    Caption = 'Trazabilidad';

                    field("Lote Interno Obligatorio"; Rec."Lote Interno Obligatorio")
                    {
                        ToolTip = 'All products must have a unique internal lot no', comment = 'ESP="Todos los productos tienen que llevar un lote interno único"';
                        ApplicationArea = all;
                    }
                    field("Lote Automatico"; Rec."Lote Automatico")
                    {
                        ToolTip = 'Automatic lot no', comment = 'ESP="Crear el Nº. de lote automáticamente"';

                        ApplicationArea = all;
                    }
                    field("Usar Lote Proveedor"; Rec."Usar Lote Proveedor")
                    {
                        ToolTip = 'For products with lot no, use the vendors lot no', comment = 'ESP="Para los productos con lote usar el lote del proveedor"';

                        ApplicationArea = all;
                    }
                    field("Lote aut. si proveedor vacio"; Rec."Lote aut. si proveedor vacio")
                    {
                        ToolTip = 'If vendors lot no empty, use the automatic lot no', comment = 'ESP="Si lote proveedor vacio, usar lote automático"';

                        ApplicationArea = all;
                    }
                    /*field("Serie Interno Obligatorio"; Rec."Serie Interno Obligatorio")
                    {
                        ToolTip = 'All products must have a unique internal lot no', comment = 'ESP="Todos los productos tienen que llevar un Nº de Serie interno único"';
                    /    ApplicationArea = all;
                    }
                    field("Usar Serie Proveedor"; Rec."Usar Serie Proveedor")
                    {
                        ToolTip = 'For products with serial no, use the vendors serial no', comment = 'ESP="Para los productos con serie usar el serie del proveedor"';
                        ApplicationArea = all;
                    }
                    field("Serie Automatico"; rec."Serie Automatico")
                    {
                        ToolTip = 'Automatic lot no', comment = 'ESP="Crear el Nº. de Serie automáticamente"';

                        ApplicationArea = all;
                    }*/

                    field("Lote unico por ubicación"; Rec."Lote unico por ubicacion")
                    {
                        ToolTip = 'Do not allow 2 lots in one bin', comment = 'ESP="No permitir 2 lotes en una ubicación"';
                        ApplicationArea = all;
                    }
                }

                group(AppEnviosRecepciones)
                {
                    Caption = 'Envíos y Recepciones';

                    field("Cantidad envio a cero"; rec."Cantidad envio a cero")
                    {
                        ApplicationArea = all;
                    }
                    field("Cantidad recepcion a cero"; Rec."Cantidad recepcion a cero")
                    {
                        ApplicationArea = All;
                    }
                }

                group(AppCodificacionAltas)
                {
                    Caption = 'New product coding', Comment = 'ESP=Codificación productos altas';
                    field("Codificacion Personalizada"; Rec."Codificacion Personalizada")
                    {
                        ApplicationArea = all;
                    }
                    field("Digitos Producto"; Rec."Digitos Producto")
                    {
                        ApplicationArea = all;
                    }
                    field("Digitos Entero"; Rec."Digitos Entero")
                    {
                        ApplicationArea = all;
                    }
                    field("Digitos Decimal"; Rec."Digitos Decimal")
                    {
                        ApplicationArea = all;
                    }
                    field("Ubicacion Altas"; Rec."Ubicacion Altas")
                    {
                        ApplicationArea = all;
                    }
                }

            }
        }
    }
}