echo "IDF ENV"

export IDF_PATH="${IDF_PATH}"

# Call idf_tools.py to export tool paths
export IDF_TOOLS_EXPORT_CMD=${IDF_PATH}/export.sh
export IDF_TOOLS_INSTALL_CMD=${IDF_PATH}/install.sh
# Allow calling some IDF python tools without specifying the full path
# ${IDF_PATH}/tools is already added by 'idf_tools.py export'
IDF_ADD_PATHS_EXTRAS="${IDF_PATH}/components/esptool_py/esptool"
IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/espcoredump"
IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/partition_table"
IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/app_update"

idf_exports=$("$ESP_PYTHON" "${IDF_PATH}/tools/idf_tools.py" export "--add_paths_extras=${IDF_ADD_PATHS_EXTRAS}") || return 1
eval "${idf_exports}"
export PATH="${IDF_ADD_PATHS_EXTRAS}:${PATH}"
