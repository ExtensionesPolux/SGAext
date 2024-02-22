page 50104 Licencias
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Texto; Texto)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field(Pwd; Pwd)
                {
                    ApplicationArea = all;
                }
                field(Hash; Hash)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field(Largo; Largo)
                {
                    ApplicationArea = all;
                    BlankZero = true;
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
            action(TestCript)
            {
                ApplicationArea = All;
                Caption = 'Test Encriptación';
                Image = TestFile;
                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Test_Encriptado();
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
                Caption = 'Información Licencias';
                image = Info;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Informacion();
                end;

            }
        }
    }

    trigger OnOpenPage()
    begin
        Texto := 'En un lugar de la Mancha';
        Pwd := '_venus13';
    end;

    var
        Texto: Text;
        Pwd: Text;
        Hash: text;
        Largo: integer;


    local procedure Azure_Test()
    var
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        Stream: InStream;
        Url: Text;
        texto: text;
        t: text;

    begin
        url := 'https://polux-sga20240105130107.azurewebsites.net/api/Inicio?Code=aLS1S5LrrL4TsrUEKcOr0iJwZrY7jd07wuxXS7snT_CmAzFu3N3ObA==&Command=CRYPT-BC';

        if not client.Post(Url, Content, ResponseMessage) then exit;

        if not ResponseMessage.IsSuccessStatusCode() then exit;

        ResponseMessage.Content().ReadAs(Stream);

        texto := '';
        while not (Stream.EOS) do begin
            Stream.ReadText(t, 100);
            texto += t;
        end;

        message(texto);

    end;
}