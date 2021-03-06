# 3rd Party Libraries
{Alert, Button} = require('react-bootstrap')

# Internal & React Libraries
{React, rclass, rtypes} = require('./smc-react')
{Icon} = require('./r_misc')

alert_style =
    marginBottom : 0
    fontSize     : '13pt'

exports.DiskSpaceWarning = rclass ({name}) ->
    displayName : 'DiskSpaceWarning'

    reduxProps :
        projects :
            project_map              : rtypes.immutable.Map
            get_total_project_quotas : rtypes.func

    propTypes :
        project_id : rtypes.string

    shouldComponentUpdate: (nextProps) ->
        return @props.project_map?.get(@props.project_id) != nextProps.project_map?.get(nextProps.project_id)

    render: ->
        if not require('./customize').commercial
            return null
        quotas = @props.get_total_project_quotas(@props.project_id)
        project_status = @props.project_map?.get(@props.project_id)?.get('status')
        if not quotas?.disk_quota? or not project_status?
            return null
        else
            disk = Math.ceil(project_status.get('disk_MB') ? 0)
        if quotas.disk_quota - 5 > disk
            return null

        <Alert bsStyle='danger' style={alert_style}>
            <Icon name='exclamation-triangle' /> WARNING: This project is running out of disk space. Please increase the quota in <a onClick={=>@actions(project_id: @props.project_id).set_active_tab('settings')} style={cursor:'pointer'}>settings</a> or delete some files.
        </Alert>


exports.RamWarning = rclass ({name}) ->
    displayName : 'RAMWarning'

    reduxProps :
        projects :
            project_map              : rtypes.immutable.Map
            get_total_project_quotas : rtypes.func

    propTypes :
        project_id : rtypes.string

    shouldComponentUpdate: (nextProps) ->
        return @props.project_map?.get(@props.project_id) != nextProps.project_map?.get(nextProps.project_id)

    render: ->
        if not require('./customize').commercial
            return <span />
        quotas = @props.get_total_project_quotas(@props.project_id)
        project_status = @props.project_map?.get(@props.project_id)?.get('status')
        if not quotas?.memory? or not project_status?
            return <span />
        else
            rss = project_status.get('memory')?.get('rss')
            if not rss
                return <span />
            memory = Math.round(rss/1000)
        if quotas.memory > memory + 5
            return <span />

        <Alert bsStyle='danger' style={alert_style}>
            <Icon name='exclamation-triangle' /> WARNING: This project is running low on RAM memory.  Upgrade memory in <a onClick={=>@actions(project_id: @props.project_id).set_active_tab('settings')} style={cursor:'pointer'}>settings</a>, restart your project or kill some processes. (Memory usage is updated about once per minute.)
        </Alert>