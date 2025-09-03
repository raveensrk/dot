#!/usr/bin/env bash

# TODO Forecast

alias ,hledger_bal_assets="hledger bal --depth 3 assets --tree"
alias ,hledger_bal_assets_savings="hledger bal --depth 3 assets:savings --tree"
alias ,hledger_bal_daily_4days="hledger bal expenses --daily -b -4days"
alias ,hledger_bal_monthly="hledger bal --depth 1 --monthly"
alias ,hledger_bal_today="hledger balance expenses -t date:today"
alias ,hledger_bal_weekly="hledger bal --depth 1 --weekly"
alias ,hledger_bal_yesterday="hledger balance expenses -t date:yesterday"
[ -f  ~/dot_local/config/bash/hledger_aliases.sh ] && source ~/dot_local/config/bash/hledger_aliases.sh
