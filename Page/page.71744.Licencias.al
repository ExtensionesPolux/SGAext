page 71744 Licencias
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Dispositivos;
    Permissions = tabledata Resource = RMID;

    layout
    {
        area(Content)
        {
            group(Datos)
            {
                field(LicenciasNo; CompanyInfo."Licencias Activas")
                { }
                field(LicenciasUsadas; CompanyInfo."Licencias Usadas")
                { }
                field(FechaVto; CompanyInfo."Fecha Vto Licencias")
                { }
            }
            repeater(Control1)
            {
                field(Device; rec.Code)
                {
                    Caption = 'Id Dispositivo';
                    ApplicationArea = all;
                }

                field(IP; rec.IP)
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; rec."posting Date")
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
                    LicenseMgt: Codeunit "SGA License Management";
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
                    LicenseMgt: Codeunit "SGA License Management";
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
                    CompanyInfo.Reset;
                    CompanyInfo.Findfirst;
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
        CompanyInfo.Reset;
        CompanyInfo.Findfirst;
    end;

    var
        CompanyInfo: record "Company Information";


    local procedure Cargar_Datos()
    var
        LicenseMgt: Codeunit "SGA License Management";
    begin
        LicenseMgt.Informacion();

        rec.reset;
        rec.FindFirst();
    end;

}