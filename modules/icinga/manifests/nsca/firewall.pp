# = Class: icinga::nsca::firewall
#
# Sets up firewall rules to allow NSCA traffic on port 5667
class icinga::nsca::firewall {

    # NSCA on port 5667
    ferm::rule { 'ncsa_allowed':
        rule => 'saddr (127.0.0.1 \
          $EQIAD_PRIVATE_ANALYTICS1_A_EQIAD \
          $EQIAD_PRIVATE_ANALYTICS1_B_EQIAD \
          $EQIAD_PRIVATE_ANALYTICS1_C_EQIAD \
          $EQIAD_PRIVATE_ANALYTICS1_D_EQIAD \
          $EQIAD_PRIVATE_PRIVATE1_A_EQIAD \
          $EQIAD_PRIVATE_PRIVATE1_B_EQIAD \
          $EQIAD_PRIVATE_PRIVATE1_C_EQIAD \
          $EQIAD_PRIVATE_PRIVATE1_D_EQIAD \
          $EQIAD_PUBLIC_PUBLIC1_A_EQIAD \
          $EQIAD_PUBLIC_PUBLIC1_B_EQIAD \
          $EQIAD_PUBLIC_PUBLIC1_C_EQIAD \
          $EQIAD_PUBLIC_PUBLIC1_D_EQIAD \
          $ESAMS_PRIVATE_PRIVATE1_ESAMS \
          $ESAMS_PUBLIC_PUBLIC1_ESAMS \
          $ULSFO_PRIVATE_PRIVATE1_ULSFO \
          $ULSFO_PUBLIC_PUBLIC1_ULSFO \
          $EQIAD_PUBLIC_FRACK_EXTERNAL1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_PAYMENTS1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_BASTION1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_ADMINISTRATION1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_FUNDRAISING1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_DMZ1_C_EQIAD \
          $EQIAD_PRIVATE_FRACK_LISTENERDMZ1_C_EQIAD \
          $CODFW_PUBLIC_FRACK_EXTERNAL_CODFW \
          $CODFW_PRIVATE_FRACK_PAYMENTS_CODFW \
          $CODFW_PRIVATE_FRACK_BASTION_CODFW \
          $CODFW_PRIVATE_FRACK_ADMINISTRATION_CODFW \
          $CODFW_PRIVATE_FRACK_FUNDRAISING_CODFW \
          $CODFW_PRIVATE_FRACK_LISTENERDMZ_CODFW \
          $CODFW_PRIVATE_FRACK_MANAGEMENT_CODFW \
          ) proto tcp dport 5667 ACCEPT;',
    }
}
