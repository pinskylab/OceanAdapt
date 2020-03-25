## For [SEUS]
# 1. Using Chrome or Firefox (not Safari) visit the website: ("https://www2.dnr.sc.gov/seamap/Account/LogOn?ReturnUrl=%2fseamap%2fReports")
# 2. Login using the pinsky username and password or create your own account.
# 3. Click on Coastal Trawl Survey Extraction.
# 4. Select "Event Information" from the drop down menu.
# 5. For all of the remaining boxes, click on the <- arrow on the upper right side of each box to move all options over to the left.  Sometimes these pop back over to the right so wait a while to make sure everything sticks.
# 6. Click create report.
# 7. Update the line below to point to the downloaded file (change ~/Downloads/pinsky to wherever your file downloaded and whatever it was named, pay attention that the EVENT file stays on the event line and the ABUNDANCE file stays on the abundance line.
# 8. repeat steps 4-7 for the dropdown menu item "Abundance and Biomass".

#ABUNDANCE = catch
#EVENT = haul


file.copy(from = "~/Downloads/pinsky.Coastal Survey.ABUNDANCE.2020-03-25T10.29.11.csv"", to = "data_raw/seus_catch.csv", overwrite = T)
file.copy(from = "~/Downloads/pinsky.Coastal Survey.EVENT.2020-03-25T10.29.11.csv", to = "data_raw/seus_haul.csv", overwrite = T)
