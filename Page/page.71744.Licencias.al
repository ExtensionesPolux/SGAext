page 71744 Licencias
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Resource;
    Permissions = tabledata Resource = RMID;

    layout
    {
        area(Content)
        {
            group(Datos)
            {
                field(Estado; LicenciasDatos.Estado)
                {
                    ApplicationArea = all;
                }
                field(TextoError; LicenciasDatos.Error)
                {
                    ApplicationArea = all;
                }
                field(LicenciasNo; LicenciasDatos."Licencias Activas")
                { }
                field(LicenciasUsadas; LicenciasDatos."Licencias Usadas")
                { }
            }
            repeater(Control1)
            {
                field(Device; rec."No.")
                {
                    Caption = 'Id Dispositivo';
                    ApplicationArea = all;
                }
                field(Name; rec.Name)
                {
                    ApplicationArea = All;
                }
                field(IP; rec.IP)
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; rec."Fecha Registro")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestAPI)
            {
                ApplicationArea = All;
                Caption = 'Hello Word';
                image = LinkWeb;
                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management2";
                begin
                    LicenseMgt.Test_Hola();
                end;
            }
            action(TestRegistro)
            {
                ApplicationArea = All;
                Caption = 'Test Registro';
                Image = TestFile;
                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management2";
                begin
                    LicenseMgt.Test_Registro();
                end;
            }
            action(Informacion)
            {
                ApplicationArea = all;
                Caption = 'Cargar Datos';
                image = Info;

                trigger OnAction()
                begin
                    Cargar_Datos();
                    CurrPage.Update(false);
                end;

            }

            action(TestError)
            {
                ApplicationArea = All;
                Caption = 'Test Error';
                Image = TestFile;
                trigger OnAction()
                var
                    cuWS: Codeunit WsApplicationStandard;
                begin
                    cuWS.Login('{"PIN":"2222","Location":"0"}');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Cargar_Datos();
    end;

    var
        LicenciasDatos: record Licencias;


    local procedure Cargar_Datos()
    var
        Recursos: record Resource;
        LicenseMgt: Codeunit "SGA License Management2";
    begin
        Recursos.reset;
        Recursos.SetRange("Dispositivo Movil", true);
        Recursos.deleteall;

        LicenseMgt.Informacion();

        rec.reset;
        rec.Setrange("Dispositivo Movil", True);
    end;

}