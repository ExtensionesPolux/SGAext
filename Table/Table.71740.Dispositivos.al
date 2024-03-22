table 71740 Dispositivos
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; Code; Code[20])
        {
            Caption = 'Código';
        }
        field(20; IP; code[20])
        {
            Caption = 'IP';
        }
        field(30; "posting Date"; date)
        {
            Caption = 'Fecha Registro';
        }
        field(40; Baja; Boolean)
        {
            Caption = 'Baja';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }



}