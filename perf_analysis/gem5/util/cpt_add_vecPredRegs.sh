if [ $# -gt 0 ]; then
    CKPT_FILENAME=$1
else
    echo "Your command line contains no arguments"
    exit
fi

echo "Adding vecPredRegs=00000000 after vecRegs in $CKPT_FILENAME"
sed -i '/vecRegs/a vecPredRegs=00000000' $CKPT_FILENAME
