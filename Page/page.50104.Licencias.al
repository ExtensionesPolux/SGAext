page 50104 Licencias
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Licencias;


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
                field(Device; rec.Device)
                {
                    Caption = 'Id Dispositivo';
                    ApplicationArea = all;
                }
                field(IP; rec.IP)
                {
                    Caption = 'IP Registro';
                    ApplicationArea = all;
                }
                field("Posting Date"; rec."Posting Date")
                {
                    Caption = 'Fecha Registro';
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
                Caption = 'Test API Polux';
                image = LinkWeb;
                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Test();
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
                    CurrPage.Update(false);
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
        Licencias: record Licencias;
        LicenseMgt: Codeunit "SGA License Management";
    begin
        Licencias.reset;
        Licencias.deleteall;

        LicenseMgt.Informacion(rec);

        rec.reset;
        if rec.Findfirst then LicenciasDatos.copy(rec);
        rec.setfilter(Id, '>%1', 0);
    end;

}