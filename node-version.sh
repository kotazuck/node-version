#/bin/bash

tsv_format='.date + "\t" + .version'
json_format='.'

opt_json=0
opt_cmd="list"

get_json() {
  curl -s "https://nodejs.org/dist/index.json"
}

format() {
  fmt="${tsv_format}"
  if [ ${opt_json} -eq 1 ]; then
    fmt="${json_format}"
  fi
  cat - | jq -r "${1} | ${fmt}"
}

cmd_current() {
  get_json | format '.[0]'
}

cmd_lts() {
  get_json | format '[.[]|select(.lts != false)][0]'
}

cmd_list() {
  if [ ${opt_json} -eq 1 ]; then
    get_json | format '.[]' | jq -s '.'
  else
    get_json | format '.[]'
  fi
}


while [ ${#} -gt 0 ]
do
  arg="${1}"

  case "${arg}" in
    --json)
      opt_json=1
      ;;
    current)
      opt_cmd="current"
      ;;
    lts)
      opt_cmd="lts"
      ;;
    list)
      opt_cmd="list"
      ;;
    *)
      echo "Unknow option." >&2
      exit 1
  esac

  shift
done

case "${opt_cmd}" in
  current)
    cmd_current
    ;;
  lts)
    cmd_lts
    ;;
  *)
    cmd_list
    ;;
esac

