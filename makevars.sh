for i in `seq 1 3`; do echo "location${i}_name = params[\"location${i}_name\"]"; for item in `seq 1 4`; do echo "location${i}_item${item}_name = params[\"location${i}_item${item}_name\"]"; echo "location${i}_item${item}_cost = params[\"location${i}_item${item}_cost\"]"; done; done