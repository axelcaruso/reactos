option(NO_REACTOS_BUILDNO "If true, disables the generation of buildno.h and version.h for each configure" OFF)

# --- INICIO CONFIGURACION OPENNT ---

# 1. Definimos la base interna (Para que Windows no llore, aunque no lo mostremos)
set(KERNEL_VERSION_MAJOR "1")
set(KERNEL_VERSION_MINOR "0")
set(KERNEL_VERSION_PATCH_LEVEL "0")
set(COPYRIGHT_YEAR "2025")

# 2. Calculamos los datos de fecha
string(TIMESTAMP OPENNT_WEEK "%U")       # Semana (Ej: 52)
string(TIMESTAMP OPENNT_YEAR_SHORT "%y") # Año corto (Ej: 25)

# 3. Variable de Hotfix (A, B, C...)
set(OPENNT_HOTFIX "A")

# 4. Construimos el string maestro: "52W25A" 
# (Semana "52" + W + Año "25" + Hotfix "A")
set(KERNEL_VERSION_STR "${OPENNT_WEEK}W${OPENNT_YEAR_SHORT}${OPENNT_HOTFIX}")

# --- FIN CONFIGURACION OPENNT ---

if (NOT NO_REACTOS_BUILDNO)
    # Aquí está el truco: En vez de la fecha, le enchufamos TU variable
    # Asegúrate de que este bloque esté DEBAJO de donde calculamos KERNEL_VERSION_STR
    set(KERNEL_VERSION_BUILD "${KERNEL_VERSION_STR}") 
else()
    set(KERNEL_VERSION_BUILD "custom")
endif()

# Esto mantiene la compatibilidad interna de Windows para DLLs
# (Sumarle 42 es una tradición rara de NT, la dejamos para que no rompa nada)
math(EXPR REACTOS_DLL_VERSION_MAJOR "${KERNEL_VERSION_MAJOR}+42")
set(DLL_VERSION_STR "${REACTOS_DLL_VERSION_MAJOR}.${KERNEL_VERSION_MINOR}.${KERNEL_VERSION_PATCH_LEVEL}")

# Definimos KERNEL_VERSION para uso interno del compilador (semántico)
set(KERNEL_VERSION "${KERNEL_VERSION_MAJOR}.${KERNEL_VERSION_MINOR}.${KERNEL_VERSION_PATCH_LEVEL}")

# Get Git revision through "git describe"
set(COMMIT_HASH "unknown-hash")
set(REVISION "unknown-revision")

if((EXISTS "${REACTOS_SOURCE_DIR}/.git") AND (NOT NO_REACTOS_BUILDNO))
    find_package(Git)
    if(GIT_FOUND)
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
            WORKING_DIRECTORY ${REACTOS_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_COMMIT_HASH
            RESULT_VARIABLE GIT_CALL_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(GIT_CALL_RESULT EQUAL 0)
            set(COMMIT_HASH "${GIT_COMMIT_HASH}")
        endif()

        execute_process(
            COMMAND "${GIT_EXECUTABLE}" describe --abbrev=7 --long --always
            WORKING_DIRECTORY ${REACTOS_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_DESCRIBE_REVISION
            RESULT_VARIABLE GIT_CALL_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(GIT_CALL_RESULT EQUAL 0)
            set(REVISION "${GIT_DESCRIBE_REVISION}")
        endif()
    endif()
endif()

# Generamos los archivos finales
configure_file(sdk/include/reactos/version.h.cmake ${REACTOS_BINARY_DIR}/sdk/include/reactos/version.h)
configure_file(sdk/include/reactos/buildno.h.cmake ${REACTOS_BINARY_DIR}/sdk/include/reactos/buildno.h)

message(STATUS "--- OpenNT Configuration: Version ${KERNEL_VERSION_STR} ---")