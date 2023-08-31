*** Settings ***
Documentation       POLON Studio

Resource            ../Resources/RPA.Desktop.robot
Task Timeout        7 minutes

*** Variables ***
${IMAGE_FOLDER}     C:/grafika
${APP_NAME}         POLON Studio
${VALID_TEXT}       V Konfiguracja systemu jest poprawna
${EXPECTED_TEXT}    Strefy dozorowe
@{LIST_EL_6000}     e_ACR_4001    e_ADC_4001M    e_CDG_6000    e_DOP_6001    e_DOR_4046
...                 e_DOT_6046    e_DUO_6046    e_DUO_6046AD    e_DUT_6046AD    e_EKS_6008
...                 e_EKS_6044    e_EKS_6080    e_EKS_6202    e_EKS_6222P    e_EKS_6400


*** Test Cases ***
Open    [Tags]    000    start
    RPA.Desktop.Click    coordinates:100,300
    ${PS}=    RPA.Desktop.Open Application    PolonStudio.exe
    Sleep    4s
    RPA.Desktop.Press Keys    enter
    Log To Console    ${PS}
    Sleep    4s

36 - Remove MD-60 module from node nr 1    [Tags]    036    smoke
    Search Tree Element And Click Locator    ^węzeł.*.\\[1\\]    wezel_unilocator
    Find Alias Move To Offset Right Click Offset And Click    m_MD-60    0    0    30    30
    RPA.Desktop.Click    alias:Tak
    ${image_status}=    BuiltIn.Run Keyword And Return Status    RPA.Desktop.Find Element    alias:m_MD-60
    IF    ${image_status}    BuiltIn.Fail    Error removing modules
    BuiltIn.Run Keyword And Warn On Failure    Check PSO connections

39 - Add 2 modules MLD-61 to node nr 9    [Tags]    039    smoke
    Show Only Nodes In The Tree
    Find Alias Move To Offset Right Click Offset And Click    wezel_glowny    0    192    30    30
    Add Modules By Node_hub    MLD-61    2

41 - Adding your own alarm variants    [Tags]    041    smoke
    [Documentation]    Add your own alert variants with using the first and second templates
    FOR    ${v_count}    IN RANGE    0    2
        RPA.Desktop.Click    z_Warianty_alarmowania
        BuiltIn.Sleep    1
        ${number_of_variants}=    Read Text From Region With Resize Region    win_razem    5    0    40    0
        ${number_of_variants}=    BuiltIn.Evaluate    ${number_of_variants}[-2:]
        RPA.Desktop.Wait For Element    Nowy
        RPA.Desktop.Click    Nowy
        Move To Region Click Offset And Click    win_wariant_locator    30    30
        IF    ${v_count} == 0
            RPA.Desktop.Press Keys    s    Enter
        ELSE
            RPA.Desktop.Press Keys    s
            BuiltIn.Sleep    1        
            RPA.Desktop.Press Keys    s    Enter
        END
        Move To Region Offset And Click    win_opis    30    0
        RPA.Windows.Send Keys    keys=New alerting variant created by the user from the template
        RPA.Desktop.Click    win_tryb_ROP_II_st.
        RPA.Desktop.Click    win_nie
        RPA.Desktop.Click    win_wybierz_strefy
        FOR    ${counter}    IN RANGE    0    3   
            IF    ${counter} == 2
                RPA.Desktop.Press Keys    End
            END
            Move To Region Offset And Click    win_dostepne_zasoby    0    30
            RPA.Desktop.Click    win_left_red_arrow
        END
        RPA.Desktop.Click    Zapis
        RPA.Desktop.Click    Dodaj
        Check The Number Of Item After The Change    ${number_of_variants}
    END

*** Keywords ***
Remove Modules From Node
    [Arguments]    ${node_number}    ${module_name}    ${amount_to_remove}
    Search Tree Element And Click Locator    ^węzeł.*.\\[${node_number}\\]    wezel_unilocator    
    ${string}=    BuiltIn.Set Variable    ${module_name}
    ${module_alias}=    BuiltIn.Catenate    m_${string}
    BuiltIn.Log To Console    ${module_alias}
    ${matches}=    RPA.Desktop.Find Elements    ${module_alias}
    ${modules}=    Find Elements By Alias And Count    ${module_alias}
    IF    ${modules} < ${amount_to_remove}
        Fail     There aren't that many modules ${module_name}       
    END
    BuiltIn.Log To Console    ${modules}
    ${c}=    BuiltIn.Convert To Integer    0
    ${counter}=    Set Variable    ${c}
    FOR    ${match}    IN    @{matches}
        Move To Region Right Click Offset And Click    ${match}    30    30
        RPA.Desktop.Click    alias:Tak
        BuiltIn.Sleep    1
        ${counter}=     BuiltIn.Evaluate    ${counter}+1
        BuiltIn.Log To Console   ${counter}
        IF    ${counter} == ${amount_to_remove}    BREAK
    END
    ${matches2}=    RPA.Desktop.Find Elements    ${module_alias}
    ${modules2}=    Find Elements By Alias And Count    ${module_alias}
    BuiltIn.Log To Console    ${modules2}
    ${number_of_modules}=    BuiltIn.Evaluate    ${modules}-${amount_to_remove}
    BuiltIn.Log To Console    ${number_of_modules}
    BuiltIn.Should Be Equal As Integers    ${modules2}    ${number_of_modules}

Find Element By Locator With Warning
    [Documentation]    Checking the correctness of translations
    [Arguments]    ${picture_alias}    ${alternative_picture_alias}
    ${status}=    Run Keyword And Return Status    RPA.Desktop.Find Element    ${picture_alias}
    IF    ${status} == ${TRUE}
        RETURN    ${picture_alias}
    ELSE
        ${status}=    Run Keyword And Return Status    RPA.Desktop.Find Element    ${alternative_picture_alias}
        IF    ${status} == ${TRUE}
            BuiltIn.Log    Translation error! alias:${alternative_picture_alias}    level=WARN
            RETURN    ${alternative_picture_alias}
        ELSE
            BuiltIn.Fail    Error!, Neither alias ${picture_alias} nor ${alternative_picture_alias} exist
        END
    END

Find Elements By Alias And Count
    [Arguments]    ${picture_alias}
    ${matches}=    RPA.Desktop.Find Elements    alias:${picture_alias}
    ${count}=    BuiltIn.Get Length    ${matches}
    ${count}=    BuiltIn.Convert To Integer    ${count}
    IF    ${count} == 0    BuiltIn.Log To Console    No matching elements
    RETURN    ${count}

