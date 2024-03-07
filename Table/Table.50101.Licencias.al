table 50102 Licencias
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; Id; Integer)
        { }
        field(10; "Licencia BC"; text[100])
        { }
        field(20; "Licencia Polux"; text[100])
        { }
        field(30; "Estado"; code[10])
        { }
        field(40; "Error"; text[200])
        { }
        field(50; "Licencias Activas"; Integer)
        { }
        field(60; "Licencias Usadas"; Integer)
        { }
        field(200; "Device"; text[50])
        { }
        field(210; "IP"; code[20])
        { }
        field(220; "Posting Date"; date)
        { }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }



}